//
//  AlbumViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.09.2022.
//

import Foundation

class AlbumViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
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
            self.isAllowLoading = false
            self.isRequestStatus = .Error
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveAudio(token: String, secret: String, albumId: String, ownerId: Int, accessKey: String)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        self.model.getAudioFromAlbum(token: token,
                                     secret: secret,
                                     ownerId: ownerId,
                                     accessKey: accessKey,
                                     albumId: albumId) { count, list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        
                        if list.isEmpty
                        {
                            self.isAllowLoading = false
                            self.isRequestStatus = .Empty
                        } else {
                            self.list.removeAll()
                            self.list.append(contentsOf: list)
                            
                            self.isAllowLoading = false
                            self.isRequestStatus = .Received
                        }
                    }
                }
            }
        }
    }
}
