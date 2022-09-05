//
//  MyMusicView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 19.08.2022.
//

import SwiftUI

fileprivate class MyMusicViewModel: ObservableObject
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
            self.receiveAudio(count: 50, offset: 0)
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func refreshToken(completionHandler: @escaping ((_ success: Bool) -> Void))
    {
        if !self.isRequest {
            return
        }
        
        self.isRequest = false
        self.model.refreshToken(token: self.token, secret: self.secret) { refresh, result in
            DispatchQueue.main.async {
                var success = false
                
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred when accessing the server")
                case .Success:
                    self.token = refresh!.response.token
                    self.secret = refresh!.response.secret
                    
                    UIUtils.updateInfo(token: self.token, secret: self.secret)
                    
                    success = true
                }
                
                completionHandler(success)
            }
        }
    }
    
    func receiveAudio(count: Int, offset: Int)
    {
        self.refreshToken { success in
            guard success else {
                self.isRequest = true
                return
            }
            
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
}

struct MyMusicView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model = MyMusicViewModel()
    
    var body: some View
    {
        StackView(title: "My music", back: true)
        {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding(30)
                .removed(!self.model.list.isEmpty)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list, id:\.id) { item in
                        AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId) { type in
                            switch type {
                            case .Menu:
                                print("Menu show")
                            case .Item:
                                self.playOrPause(item: item)
                            }
                        }
                        .id(item.id)
                        .onAppear {
                            if item.id == self.model.list.last?.id && self.model.list.count >= 50 && self.model.isLoading
                            {
                                let end = self.model.list.endIndex
                                self.model.receiveAudio(count: 50, offset: end)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        } menu: {
            EmptyView()
        }
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.model.audioId == self.audioPlayer.playedModel?.model.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.model.list)
        }
    }
}
