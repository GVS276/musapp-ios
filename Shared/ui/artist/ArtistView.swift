//
//  ArtistView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.08.2022.
//

import SwiftUI

struct ArtistView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    @State private var audioList = [AudioStruct]()
    @State private var albumList = [AlbumModel]()
    
    @State private var token = ""
    @State private var secret = ""
    
    var artistModel: ArtistModel
    var body: some View
    {
        ProfileHeaderView(title: self.artistModel.name, subTitle: "") {
            Image("user")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color("color_text"))
                .frame(width: 60, height: 60)
        } content: {
            VStack(spacing: 0)
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(30)
                    .removed(!self.audioList.isEmpty || !self.albumList.isEmpty)
                
                if !self.albumList.isEmpty
                {
                    Text("Recent release")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 18))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    self.albumItem(item: self.albumList[0])
                }
                
                Text("Tracks")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .removed(self.audioList.isEmpty)
                
                ForEach(self.audioList, id: \.id) { item in
                    AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId) { type in
                        switch type {
                        case .Menu:
                            print("Menu show")
                        case .Item:
                            self.playOrPause(item: item)
                        }
                    }
                    .id(item.id)
                }
                
                self.selectorItem(title: "Show more tracks", destination: AboutView())
                    .removed(self.audioList.isEmpty)
                
                Text("Albums")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .removed(self.albumList.isEmpty)
                
                ForEach(self.albumList, id: \.id) { item in
                    self.albumItem(item: item).id(item.id)
                }
                
                self.selectorItem(title: "Show more albums", destination: AboutView())
                    .removed(self.albumList.isEmpty)
                
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
                    self.receiveTracks()
                }
            }
        }
    }
    
    private func selectorItem<D: View>(title: String, destination: D) -> some View
    {
        Button {
            RootStack.shared.pushToView(view: destination)
        } label: {
            HStack(spacing: 0)
            {
                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 15)
                
                Spacer()
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
            }
            .padding(.vertical, 10)
        }
    }
    
    private func albumItem(item: AlbumModel) -> some View
    {
        Button {
            RootStack.shared.pushToView(view: AlbumView(albumId: item.albumId,
                                                        albumName: item.title,
                                                        artistName: self.artistModel.name,
                                                        ownerId: item.ownerId,
                                                        accessKey: item.accessKey).environmentObject(self.audioPlayer))
        } label: {
            HStack(spacing: 0)
            {
                ThumbView(url: item.thumb, albumId: item.albumId, big: false)
                    .padding(.horizontal, 15)
                
                VStack
                {
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    let strYear = String(item.year)
                    let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                    
                    Text("\(strYear) • \(strCount)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
            }
            .padding(.vertical, 10)
        }
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
    
    private func receiveTracks()
    {
        self.refreshToken { success in
            guard success else {
                return
            }
            
            let model = VKViewModel.shared
            model.receiveAudioArtist(token: self.token,
                                     secret: self.secret,
                                     artistId: self.artistModel.id) { list, result in
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
                        
                        self.receiveAlbums()
                    }
                }
            }
        }
    }
    
    private func receiveAlbums()
    {
        let model = VKViewModel.shared
        model.receiveAlbumArtist(token: self.token,
                                 secret: self.secret,
                                 artistId: self.artistModel.id) { albums, result in
            
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                   Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let albums = albums {
                        self.albumList.removeAll()
                        self.albumList.append(contentsOf: albums)
                    }
                }
            }
        }
    }
}
