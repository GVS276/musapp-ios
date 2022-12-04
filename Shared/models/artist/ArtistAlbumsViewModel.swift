//
//  ArtistAlbumsViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class ArtistAlbumsViewModel: ObservableObject
{
    @Published var list = [AlbumModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let model = VKViewModel.shared
    private var artistId = ""
    private var token = ""
    private var secret = ""
    
    private let maxCount = 50
    
    init(artistId: String)
    {
        if let info = UIUtils.getInfo()
        {
            self.artistId = artistId
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveAlbums(offset: 0)
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
    
    func receiveAlbums(offset: Int)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        self.model.receiveAlbumArtist(token: self.token,
                                      secret: self.secret,
                                      artistId: self.artistId,
                                      count: self.maxCount,
                                      offset: offset) { count, list, result in
            
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
                            self.isRequestStatus = self.list.isEmpty ? .Empty : .ReceivedLast
                        } else {
                            self.list.append(contentsOf: list)
                            self.isAllowLoading = count > self.maxCount
                            self.isRequestStatus = .Received
                        }
                        
                    }
                }
            }
        }
    }
}
