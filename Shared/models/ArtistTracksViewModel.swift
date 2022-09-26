//
//  ArtistTracksViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class ArtistTracksViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .Receiving
    
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
                self.receiveAudio(offset: 0)
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
    
    func receiveAudio(offset: Int)
    {
        if !self.isAllowLoading {
            return
        }
        
        self.model.receiveAudioArtist(token: self.token,
                                      secret: self.secret,
                                      artistId: self.artistId,
                                      count: self.maxCount,
                                      offset: offset) { list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        
                        if list.isEmpty
                        {
                            self.isAllowLoading = false
                            self.isRequestStatus = self.list.isEmpty ? .Empty : .ReceivedLast
                        } else {
                            self.list.append(contentsOf: list)
                            self.isAllowLoading = list.count == self.maxCount
                            self.isRequestStatus = .Received
                        }
                        
                    }
                }
            }
        }
    }
}
