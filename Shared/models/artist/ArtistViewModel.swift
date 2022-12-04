//
//  ArtistViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class ArtistViewModel: ObservableObject
{
    @Published var audioList = [AudioModel]()
    @Published var albumList = [AlbumModel]()
    
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let model = VKViewModel.shared
    
    init(artistId: String)
    {
        if let info = UIUtils.getInfo()
        {
            let token = info["token"] as! String
            let secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveTracks(token: token, secret: secret, artistId: artistId)
            }
        } else {
            self.isAllowLoading = false
            self.isRequestStatus = .Error
        }
    }
    
    deinit
    {
        self.audioList.removeAll()
        self.albumList.removeAll()
    }
    
    private func receiveTracks(token: String, secret: String, artistId: String)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        self.model.receiveAudioArtist(token: token, secret: secret, artistId: artistId) { count, list, result in
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
                            self.isRequestStatus = self.audioList.isEmpty ? .Empty : .ReceivedLast
                        } else {
                            self.audioList.removeAll()
                            self.audioList.append(contentsOf: list)
                            self.receiveAlbums(token: token, secret: secret, artistId: artistId)
                            
                            self.isAllowLoading = false
                            self.isRequestStatus = .Received
                        }
                        
                    }
                }
            }
        }
    }
    
    private func receiveAlbums(token: String, secret: String, artistId: String)
    {
        self.model.receiveAlbumArtist(token: token, secret: secret, artistId: artistId) { count, list, result in
            DispatchQueue.main.async {
                if result == .Success
                {
                    if let list = list {
                        self.albumList.removeAll()
                        self.albumList.append(contentsOf: list)
                    }
                }
            }
        }
    }
}
