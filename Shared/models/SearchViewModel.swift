//
//  SearchViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class SearchViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = false
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var query: String = ""
    
    private let maxCount = 50
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
        } else {
            self.isAllowLoading = false
            self.isRequestStatus = .Error
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    func startReceiveAudio(q: String)
    {
        self.query = q
        self.list.removeAll()
        
        self.isAllowLoading = true
        self.isRequestStatus = .Receiving
        
        self.receiveAudio(offset: 0)
    }
    
    func receiveAudio(offset: Int)
    {
        if !self.isAllowLoading {
            return
        }
        
        self.model.searchAudio(token: self.token,
                               secret: self.secret,
                               q: self.query, count: self.maxCount, offset: offset) { list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    print("Problems with the Internet")
                case .ErrorRequest:
                    print("An error occurred while accessing the list")
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
