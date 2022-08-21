//
//  PopularView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 18.08.2022.
//

import SwiftUI

struct PopularView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @State private var searchList = [AudioStruct]()

    @State private var token = ""
    @State private var secret = ""
    
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
                            Button {
                                self.audioPlayer.addAudioToDB(model: item)
                            } label: {
                                Text("Add audio")
                                    .foregroundColor(Color("color_text"))
                                    .font(.system(size: 16))
                            }
                        }
                        .id(item.id)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(title: "Popular music", back: true, leading: HStack {}, trailing: HStack {
            Spacer()
            
            Button {
                if !self.searchList.isEmpty
                {
                    self.searchList.removeAll()
                }
                self.receivePopularAudio()
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
                
                // delay 1 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.receivePopularAudio()
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
    
    private func receivePopularAudio()
    {
        if self.token.isEmpty || self.secret.isEmpty
        {
            return
        }
        
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
                    
                    model.popularAudio(token: self.token, secret: self.secret) { list, listResult in
                        DispatchQueue.main.async {
                        }
                        
                        switch listResult {
                        case .ErrorInternet:
                            Toast.shared.show(text: "Problems with the Internet")
                        case .ErrorRequest:
                            Toast.shared.show(text: "An error occurred while accessing the list")
                        case .Success:
                            if let list = list {
                                self.searchList.append(contentsOf: list)
                            }
                        }
                    }
                }
            }
        }
    }
}
