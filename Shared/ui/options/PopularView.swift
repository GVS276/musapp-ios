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
                self.searchList.removeAll()
                self.receiveAudio()
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
                    self.receiveAudio()
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
    
    private func refreshToken(completionHandler: @escaping ((_ success: Bool) -> Void))
    {
        let model = VKViewModel.shared
        model.refreshToken(token: self.token, secret: self.secret) { refresh, result in
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
    
    private func receiveAudio()
    {
        if self.token.isEmpty || self.secret.isEmpty
        {
            return
        }
        
        self.refreshToken { success in
            guard success else {
                return
            }
            
            let model = VKViewModel.shared
            model.popularAudio(token: self.token, secret: self.secret) { list, result in
                DispatchQueue.main.async {
                    switch result {
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
