//
//  ArtistViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class ArtistViewModel: ObservableObject
{
    @Published var audioList = [AudioStruct]()
    @Published var albumList = [AlbumModel]()
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    
    init(artistId: String)
    {
        if let info = UIUtils.getInfo()
        {
            let token = info["token"] as! String
            let secret = info["secret"] as! String
            self.receiveTracks(token: token, secret: secret, artistId: artistId)
        } else {
            self.isLoading = false
        }
    }
    
    deinit
    {
        self.audioList.removeAll()
        self.albumList.removeAll()
    }
    
    private func receiveTracks(token: String, secret: String, artistId: String)
    {
        self.model.receiveAudioArtist(token: token, secret: secret, artistId: artistId) { list, result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        self.audioList.removeAll()
                        self.audioList.append(contentsOf: list)
                    }
                    
                    self.receiveAlbums(token: token, secret: secret, artistId: artistId)
                }
            }
        }
    }
    
    private func receiveAlbums(token: String, secret: String, artistId: String)
    {
        self.model.receiveAlbumArtist(token: token, secret: secret, artistId: artistId) { list, result in
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
