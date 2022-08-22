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
    @Published var thumb: Thumb?
    
    private var thumbUrl: String
    private var thumbAlbumId: String
    
    private var isProcessPublisher = false
    private var processPublisher: AnyCancellable? = nil
    private static let processQueue = DispatchQueue(label: "thumb-process-queue")
    
    init(thumbUrl: String, thumbAlbumId: String, thumb: Thumb)
    {
        self.thumbUrl = thumbUrl
        self.thumbAlbumId = thumbAlbumId
        self.thumb = thumb
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
        
        guard !self.isProcessPublisher else {
            return
        }
        
        guard let url = URL(string: self.thumbUrl) else {
            return
        }
        
        guard self.thumb?[self.thumbAlbumId] == nil else {
            return
        }
        
        self.processPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { value in
                    self.isProcessPublisher = true
                }, receiveOutput: { value in
                    print("Processing (thumb) --")
                }, receiveCompletion: { value in
                    self.isProcessPublisher = false
                }, receiveCancel: {
                    self.isProcessPublisher = false
                }, receiveRequest: { value in
                    print("Processing (thumb) ++")
                }
            )
            .subscribe(on: Self.processQueue)
            .receive(on: DispatchQueue.main)
            .sink {
                self.thumb?[self.thumbAlbumId] = $0
            }
    }
    
    private func cancel()
    {
        self.processPublisher?.cancel()
        self.processPublisher = nil
    }
}
