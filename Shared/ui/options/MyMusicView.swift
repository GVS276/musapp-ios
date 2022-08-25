//
//  MyMusicView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 19.08.2022.
//

import SwiftUI

struct MyMusicView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    @State private var searchList = [AudioStruct]()
    @State private var loading: Bool = false
    @State private var notAnymore: Bool = false
    
    @State private var token = ""
    @State private var secret = ""
    @State private var userId: Int64 = -1
    
    private let paginationCount = 50
    private let paginationOffset = 0
    
    var body: some View
    {
        ZStack
        {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .removed(!self.searchList.isEmpty)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.searchList, id:\.id) { item in
                        AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId) {
                            self.playOrPause(item: item)
                        } menuContent: {
                            if self.audioPlayer.isAddedAudio(audioId: item.model.audioId)
                            {
                                Button {
                                    self.audioPlayer.deleteAudioFromDB(audioId: item.model.audioId)
                                } label: {
                                    Text("Delete from library")
                                        .foregroundColor(Color("color_text"))
                                        .font(.system(size: 16))
                                }
                            } else {
                                Button {
                                    self.audioPlayer.addAudioToDB(model: item)
                                } label: {
                                    Text("Add audio")
                                        .foregroundColor(Color("color_text"))
                                        .font(.system(size: 16))
                                }
                            }
                            
                            Button {
                                
                            } label: {
                                Text("Go to artist")
                                    .foregroundColor(Color("color_text"))
                                    .font(.system(size: 16))
                            }
                            .removed(item.model.artists.isEmpty)
                            
                            Button {
                                
                            } label: {
                                Text("Go to album")
                                    .foregroundColor(Color("color_text"))
                                    .font(.system(size: 16))
                            }
                            .removed(item.model.albumId.isEmpty)
                        }
                        .id(item.id)
                        .onAppear {
                            self.audioAppear(audio: item)
                        }
                        
                        if !self.notAnymore && self.loading && UIUtils.isLastAudio(list: self.searchList, audio: item) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(10)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(title: "My music", back: true, leading: HStack {}, trailing: HStack {
            Spacer()
            
            Button {
                self.searchList.removeAll()
                self.startReceiveAudio()
            } label: {
                Image("action_refresh")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        })
        .background(Color("color_background"))
        .onAppear{
            if let info = UIUtils.getInfo()
            {
                self.token = info["token"] as! String
                self.secret = info["secret"] as! String
                self.userId = info["userId"] as! Int64
                
                // delay 1 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startReceiveAudio()
                }
            }
        }
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.model.audioId == self.audioPlayer.playedModel?.model.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.searchList)
        }
    }
    
    private func startReceiveAudio()
    {
        self.notAnymore = false
        self.receiveAudio(count: self.paginationCount, offset: 0) { list in
            self.searchList.append(contentsOf: list)
        }
    }
    
    private func refreshToken(completionHandler: @escaping ((_ success: Bool) -> Void))
    {
        let model = VKViewModel.shared
        model.refreshToken(token: self.token, secret: self.secret) { refresh, result in
            DispatchQueue.main.async {
                var success = false
                
                switch result {
                case .ErrorInternet:
                    self.hideLoading()
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    self.hideLoading()
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
    
    private func receiveAudio(count: Int, offset: Int, completionHandler: @escaping ((_ list: [AudioStruct]) -> Void))
    {
        self.refreshToken { success in
            guard success else {
                return
            }
            
            let model = VKViewModel.shared
            model.getAudioList(token: self.token,
                               secret: self.secret,
                               userId: self.userId,
                               count: count,
                               offset: offset) { list, result in
                DispatchQueue.main.async {
                    switch result {
                    case .ErrorInternet:
                        self.hideLoading()
                        Toast.shared.show(text: "Problems with the Internet")
                    case .ErrorRequest:
                        self.hideLoading()
                        Toast.shared.show(text: "An error occurred while accessing the list")
                    case .Success:
                        if let list = list {
                            completionHandler(list)
                        }
                    }
                }
            }
        }
    }
    
    private func audioAppear(audio: AudioStruct)
    {
        if self.token.isEmpty || self.secret.isEmpty || self.userId == -1 || self.notAnymore
        {
            return
        }
        
        if UIUtils.isPagination(list: self.searchList, audio: audio, offset: self.paginationOffset)
        {
            let startIndex = self.searchList.endIndex
            self.loading = true
            
            self.receiveAudio(count: self.paginationCount, offset: startIndex) { list in
                self.hideLoading()
                guard !list.isEmpty else {
                    self.notAnymore = true
                    return
                }
                self.searchList.append(contentsOf: list)
            }
        }
    }
    
    private func hideLoading()
    {
        withAnimation {
            self.loading = false
        }
    }
}
