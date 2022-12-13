//
//  PlaylistViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import Foundation

class PlaylistViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let playlistId: String
    private let ownerId: String
    private let accessKey: String
    private let maxCount = 50
    
    init(playlistId: String, ownerId: String, accessKey: String)
    {
        self.playlistId = playlistId
        self.ownerId = ownerId
        self.accessKey = accessKey
        
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveAudio(offset: 0)
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
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKPlaylist.shared.request(playlistId: playlistId,
                                  ownerId: ownerId,
                                  accessKey: accessKey,
                                  count: maxCount,
                                  offset: offset) { playlist, list, result in
            
            DispatchQueue.main.async {
                
                guard result == .Success, let list = list else {
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    return
                }

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
