//
//  ThumbModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 20.08.2022.
//

import UIKit
import Combine

class ThumbModel: ObservableObject
{
    @Published var cache = ThumbCacheObj.cache
    
    private var thumbUrl: String
    private var thumbAlbumId: String
    
    private var processPublisher: AnyCancellable? = nil
    
    init(thumbUrl: String, thumbAlbumId: String)
    {
        self.thumbUrl = thumbUrl
        self.thumbAlbumId = thumbAlbumId
    }
    
    deinit {
        self.cancel()
    }
    
    func receiveThumb()
    {
        if self.thumbAlbumId.isEmpty || self.thumbUrl.isEmpty
        {
            return
        }
        
        guard let url = URL(string: self.thumbUrl) else {
            return
        }
        
        guard self.cache[self.thumbAlbumId] == nil else {
            return
        }
        
        self.processPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { value in
                    print("Thumb: received from URL")
                }, receiveOutput: { value in
                    value.map {
                        self.create(albumId: self.thumbAlbumId, image: $0)
                    }
                }
            )
            .subscribe(on: BaseTask.dqueue)
            .receive(on: DispatchQueue.main)
            .sink {
                self.cache[self.thumbAlbumId] = $0
            }
    }
    
    private func cancel()
    {
        self.processPublisher?.cancel()
        self.processPublisher = nil
    }
    
    private func create(albumId: String, image: UIImage)
    {
        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        if let fileUrl = UIFileUtils.getAnyFileUri(path: THUMB_PATH, fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                UIFileUtils.removeFile(fileUrl: fileUrl)
            }
            
            UIFileUtils.createFile(path: fileUrl.path, data: data)
            print("Processing (thumb): added on disk")
        }
    }
}
