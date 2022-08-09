//
//  SearchView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import SwiftUI

struct SearchView: View
{
    @EnvironmentObject var audioPlayer: AudioPlayerModelView

    @State private var search = ""
    @State private var token = ""
    @State private var secret = ""
    
    private var searchMax = 25
    private var searchOffset = 10
    
    private func modelBinding(_ item: AudioStruct) -> Binding<AudioStruct>? {
        guard let index = self.audioPlayer.searchList.firstIndex(where: { $0.id == item.id }) else { return nil }
        return .init(get: { self.audioPlayer.searchList[index] },
                     set: { self.audioPlayer.searchList[index] = $0 })
    }
    
    var body: some View
    {
        VStack(spacing: 15)
        {
            HStack(spacing: 15)
            {
                TextField("", text: self.$search)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .placeholder(shouldShow: self.search.isEmpty, title: "For example: slowed", bg: Color("color_toolbar"))
                    .cornerRadius(10)
                    .onTapGesture {}
                
                Button {
                    self.hideKeyBoard()
                    if !self.audioPlayer.searchList.isEmpty
                    {
                        self.audioPlayer.stop()
                        self.audioPlayer.searchList.removeAll()
                    }
                    self.startSearchAudio()
                } label: {
                    Image("action_search")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                .frame(width: 30, height: 30)
            }
            .padding(.top, 15)
            .padding(.horizontal, 15)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.audioPlayer.searchList, id:\.id) { item in
                        self.modelBinding(item).map { bind in
                            self.audioItem(bind: bind)
                                .id(item.id)
                                .onAppear {
                                    self.audioAppear(audio: item)
                                }
                        }
                    }
                }
            }
        }
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .viewTitle("Search", leading: HStack {}, trailing: HStack {})
        .onTapGesture {
            self.hideKeyBoard()
        }
    }
    
    private func playedTrack() -> some View
    {
        ZStack
        {
            Color.blue.frame(maxWidth: .infinity, maxHeight: .infinity)
            Image("play")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
    }
    
    private func audioItem(bind: Binding<AudioStruct>) -> some View
    {
        let item = bind.wrappedValue
        return HStack(spacing: 0)
        {
            ZStack
            {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(10)
            }
            .background(Color("color_thumb"))
            .overlay(self.playedTrack().removed(!item.isPlaying))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
            VStack
            {
                Text(item.model.artist)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                Text("\(item.model.title) / \(UIUtils.getTimeFromDuration(sec: Int(item.model.duration)))")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
            }
            
            Button {
                self.audioPlayer.addAudioToDB(model: bind.wrappedValue)
            } label: {
                Image("action_add")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
        .background(Color("color_background"))
        .padding(.bottom, 15)
        .onTapGesture {
            self.playOrPause(bind: bind)
        }
    }
    
    private func playOrPause(bind: Binding<AudioStruct>)
    {
        let item = bind.wrappedValue
        if item.id == self.audioPlayer.playedId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(url: item.model.streamUrl, playedId: item.id, mode: .FromSearch)
        }
    }
    
    private func startSearchAudio()
    {
        if let login = UserDefaults.standard.object(forKey: "login") as? String,
           let password = UserDefaults.standard.object(forKey: "password") as? String
        {
            let model = VKViewModel.shared
            model.doAuth(login: login, password: password) { info in
                self.token = info.access_token
                self.secret = info.secret
                self.searchAudio(count: self.searchMax, offset: self.searchOffset) { list in
                    self.audioPlayer.setSearchList(list: list)
                }
            }
        }
    }
    
    private func searchAudio(count: Int, offset: Int, completionHandler: @escaping ((_ list: [AudioStruct]) -> Void))
    {
        let model = VKViewModel.shared
        model.refreshToken(token: self.token, secret: self.secret) { refresh in
            self.token = refresh.response.token
            self.secret = refresh.response.secret
            
            model.searchAudio(token: refresh.response.token,
                              secret: refresh.response.secret,
                              q: self.search, count: count, offset: offset) { list in
                completionHandler(list)
            }
        }
    }
    
    private func isPagination(offset: Int, audio: AudioStruct) -> Bool
    {
        guard !self.audioPlayer.searchList.isEmpty else {
            return false
        }
        
        guard let itemIndex = self.audioPlayer.searchList.lastIndex(where: { AnyHashable($0.id) == AnyHashable(audio.id) }) else {
            return false
        }
        
        let distance = self.audioPlayer.searchList.distance(from: itemIndex, to: self.audioPlayer.searchList.endIndex)
        let offset = offset < self.audioPlayer.searchList.count ? offset : self.audioPlayer.searchList.count - 1
        return offset == (distance - 1)
    }
    
    private func audioAppear(audio: AudioStruct)
    {
        if self.token.isEmpty && self.secret.isEmpty
        {
            return
        }
        
        if self.isPagination(offset: self.searchOffset, audio: audio)
        {
            let startIndex = self.audioPlayer.searchList.endIndex + 1
            self.searchAudio(count: self.searchMax, offset: startIndex) { list in
                guard !list.isEmpty else { return }
                self.audioPlayer.setSearchList(list: list)
            }
        }
    }
}
