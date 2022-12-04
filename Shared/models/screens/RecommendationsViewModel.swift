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
    
    private let model = VKViewModel.shared
    
    private var audioId = ""
    private var audioOwnerId = ""
    
    private var token = ""
    private var secret = ""
    
    init(audioId: String, audioOwnerId: String)
    {
        if let info = UIUtils.getInfo()
        {
            self.audioId = audioId
            self.audioOwnerId = audioOwnerId
            
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveAudio()
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
        
        self.model.getRecommendationsAudio(token: self.token,
                                           secret: self.secret,
                                           audioId: self.audioId,
                                           audioOwnerId: self.audioOwnerId) { count, list, result in
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
