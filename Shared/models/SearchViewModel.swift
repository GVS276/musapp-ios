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
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var query: String = ""
    
    private var isRequest = true
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
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
        self.receiveAudio(count: 50, offset: 0)
    }
    
    func receiveAudio(count: Int, offset: Int)
    {
        if !self.isRequest {
            return
        }
        
        self.isRequest = false
        
        self.model.searchAudio(token: self.token,
                               secret: self.secret,
                               q: self.query, count: count, offset: offset) { list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    print("Problems with the Internet")
                case .ErrorRequest:
                    print("An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        guard !list.isEmpty else {
                            self.isLoading = false
                            return
                        }
                        
                        self.isLoading = true
                        self.list.append(contentsOf: list)
                    }
                }
                self.isRequest = true
            }
        }
    }
}
