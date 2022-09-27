//
//  MyMusicViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class MyMusicViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var userId: Int64 = -1
    
    private let maxCount = 50
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            self.userId = info["userId"] as! Int64
            
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
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        self.model.getAudioList(token: self.token,
                                secret: self.secret,
                                userId: self.userId,
                                count: self.maxCount,
                                offset: offset) { list, result in
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
                            self.isAllowLoading = list.count == self.maxCount
                            self.isRequestStatus = .Received
                        }
                        
                    }
                }
            }
        }
    }
}
