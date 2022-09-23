//
//  AlbumViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.09.2022.
//

import Foundation

class AlbumViewModel: ObservableObject
{
    @Published var list = [AudioStruct]()
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    
    init(albumId: String, ownerId: Int, accessKey: String)
    {
        if let info = UIUtils.getInfo()
        {
            let token = info["token"] as! String
            let secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveAudio(token: token, secret: secret,
                                  albumId: albumId, ownerId: ownerId, accessKey: accessKey)
            }
        } else {
            self.isLoading = false
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveAudio(token: String, secret: String, albumId: String, ownerId: Int, accessKey: String)
    {
        self.model.getAudioFromAlbum(token: token,
                                     secret: secret,
                                     ownerId: ownerId,
                                     accessKey: accessKey,
                                     albumId: albumId) { list, result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        self.list.removeAll()
                        self.list.append(contentsOf: list)
                    }
                }
            }
        }
    }
}
