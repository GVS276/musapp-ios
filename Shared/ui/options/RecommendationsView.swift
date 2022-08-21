//
//  RecommendationsView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 18.08.2022.
//

import SwiftUI

struct RecommendationsView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @State private var searchList = [AudioStruct]()

    @State private var token = ""
    @State private var secret = ""
    @State private var userId: Int64 = -1
    
    private var searchMax = 25
    private var searchOffset = 10
    
    var body: some View
    {
        ZStack
        {
            Text("We get recommendations....")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(30)
                .removed(!self.searchList.isEmpty)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.searchList, id:\.id) { item in
                        AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId) {
                            self.playOrPause(item: item)
                        } menuContent: {
                            Button {
                                self.audioPlayer.addAudioToDB(model: item)
                            } label: {
                                Text("Add audio")
                                    .foregroundColor(Color("color_text"))
                                    .font(.system(size: 16))
                            }
                        }
                        .id(item.id)
                        .onAppear {
                            self.audioAppear(audio: item)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(title: "Recommendations", back: true, leading: HStack {}, trailing: HStack {})
        .background(Color("color_background"))
        .onAppear{
            if let info = UIUtils.getInfo()
            {
                self.token = info["token"] as! String
                self.secret = info["secret"] as! String
                self.userId = info["userId"] as! Int64
                
                // delay 1 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startSearchAudio()
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
    
    private func startSearchAudio()
    {
        self.searchAudio(count: self.searchMax, offset: 0) { list in
            self.searchList.append(contentsOf: list)
        }
    }
    
    private func searchAudio(count: Int, offset: Int, completionHandler: @escaping ((_ list: [AudioStruct]) -> Void))
    {
        let model = VKViewModel.shared
        model.refreshToken(token: self.token, secret: self.secret) { refresh, result in
            switch result {
            case .ErrorInternet:
                DispatchQueue.main.async {
                    Toast.shared.show(text: "Problems with the Internet")
                }
            case .ErrorRequest:
                DispatchQueue.main.async {
                    Toast.shared.show(text: "An error occurred when accessing the server")
                }
            case .Success:
                if let refresh = refresh
                {
                    self.token = refresh.response.token
                    self.secret = refresh.response.secret
                    
                    UIUtils.updateInfo(token: self.token, secret: self.secret)
                    
                    model.recommendationsAudio(token: self.token,
                                               secret: self.secret,
                                               userId: self.userId,
                                               count: count,
                                               offset: offset) { list, listResult in
                        DispatchQueue.main.async {
                            switch listResult {
                            case .ErrorInternet:
                                Toast.shared.show(text: "Problems with the Internet")
                            case .ErrorRequest:
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
        }
    }
    
    private func audioAppear(audio: AudioStruct)
    {
        if self.token.isEmpty || self.secret.isEmpty || self.userId == -1
        {
            return
        }
        
        if UIUtils.isPagination(list: self.searchList, audio: audio, offset: self.searchOffset)
        {
            let startIndex = self.searchList.endIndex
            self.searchAudio(count: self.searchMax, offset: startIndex) { list in
                guard !list.isEmpty else { return }
                self.searchList.append(contentsOf: list)
            }
        }
    }
}
