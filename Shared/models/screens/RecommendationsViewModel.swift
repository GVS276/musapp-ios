//
//  RecommendationsViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 27.09.2022.
//

import Foundation

class RecommendationsViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private var audioId = ""
    private var audioOwnerId = ""
    
    init(audioId: String, audioOwnerId: String)
    {
        self.audioId = audioId
        self.audioOwnerId = audioOwnerId
        
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveAudio()
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveAudio()
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKAudioRecommendations.shared.request(audioId: audioId,
                                              audioOwnerId: audioOwnerId) { count, list, result in
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
