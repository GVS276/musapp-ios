//
//  AlbumView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.08.2022.
//

import SwiftUI

struct AlbumView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    @State private var audioList = [AudioStruct]()
    @State private var token = ""
    @State private var secret = ""
    
    var albumId: String
    var albumName: String
    var artistName: String
    var ownerId: Int
    var accessKey: String
    var count: Int
    
    var body: some View
    {
        ProfileHeaderView(title: self.albumName, subTitle: self.artistName) {
            if let image = ThumbCacheObj.cache[self.albumId] {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 150, maxHeight: 150)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 20, x: 0, y: 0)
            } else {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .frame(width: 60, height: 60)
            }
        } content: {
            VStack(spacing: 0)
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(30)
                    .removed(!self.audioList.isEmpty)
                
                ForEach(self.audioList, id:\.id) { item in
                    self.audioItem(item: item).id(item.id)
                }
                
                Spacer()
            }
        }
        .onAppear {
            guard self.token.isEmpty, self.secret.isEmpty else {
                return
            }
            
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
    
    private func audioItem(item: AudioStruct) -> some View
    {
        HStack(spacing: 0)
        {
            Button {
                self.playOrPause(item: item)
            } label: {
                HStack(spacing: 15)
                {
                    Text(self.getIndex(id: item.id))
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 12))
                        .frame(width: 25, height: 25)
                    
                    VStack
                    {
                        Text(item.model.title)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                        
                        HStack {
                            Text("E")
                                .foregroundColor(Color("color_text"))
                                .font(.system(size: 8))
                                .padding(.horizontal, 2)
                                .border(Color("color_text"))
                                .removed(!item.model.isExplicit)
                            
                            Text(item.model.duration.toTime())
                                .foregroundColor(Color("color_text"))
                                .font(.system(size: 14))
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            .buttonStyle(AudioButtonStyle())
            
            Menu {
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
            } label: {
                Image("action_menu")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }
        }
        .padding(.vertical, 10)
        .background(item.model.audioId == self.audioPlayer.playedModel?.model.audioId ? Color("color_playing") : Color.clear)
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.model.audioId == self.audioPlayer.playedModel?.model.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.audioList)
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
        self.refreshToken { success in
            guard success else {
                return
            }
            
            let model = VKViewModel.shared
            model.getAudioFromAlbum(token: self.token,
                                    secret: self.secret,
                                    ownerId: self.ownerId,
                                    accessKey: self.accessKey,
                                    albumId: self.albumId,
                                    count: self.count) { list, result in
                DispatchQueue.main.async {
                    switch result {
                    case .ErrorInternet:
                        Toast.shared.show(text: "Problems with the Internet")
                    case .ErrorRequest:
                        Toast.shared.show(text: "An error occurred while accessing the list")
                    case .Success:
                        if let list = list {
                            self.audioList.removeAll()
                            self.audioList.append(contentsOf: list)
                        }
                    }
                }
            }
        }
    }
    
    private func getIndex(id: String) -> String
    {
        let index = self.audioList.firstIndex(where: {$0.id == id}) ?? -1
        return index == -1 ? "•" : String(index + 1)
    }
}
