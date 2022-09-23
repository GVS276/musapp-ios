//
//  MyMusicViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class MyMusicViewModel: ObservableObject
{
    @Published var list = [AudioStruct]()
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var userId: Int64 = -1
    
    private var isRequest = true
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            self.userId = info["userId"] as! Int64
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveAudio(count: 50, offset: 0)
            }
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    func receiveAudio(count: Int, offset: Int)
    {
        if !self.isRequest {
            return
        }
        
        self.isRequest = false
        
        self.model.getAudioList(token: self.token,
                                secret: self.secret,
                                userId: self.userId,
                                count: count,
                                offset: offset) { list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred while accessing the list")
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
