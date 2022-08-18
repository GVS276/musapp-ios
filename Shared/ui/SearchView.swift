//
//  SearchView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import SwiftUI

struct SearchView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @State private var searchList = [AudioStruct]()

    @State private var search = ""
    @State private var token = ""
    @State private var secret = ""
    
    private var searchMax = 25
    private var searchOffset = 10
    
    private func binding(_ item: AudioStruct) -> Binding<AudioStruct>
    {
        guard let index = self.searchList.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Can't find item in array")
        }
        return self.$searchList[index]
    }
    
    var body: some View
    {
        VStack
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.searchList, id:\.id) { item in
                        self.audioItem(bind: self.binding(item))
                            .id(item.id)
                            .onAppear {
                                self.audioAppear(audio: item)
                            }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(back: true, leading: HStack {
            TextField("Search...", text: self.$search)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .onTapGesture {}
        }, trailing: HStack {
            Spacer()
            
            Button {
                self.search.removeAll()
            } label: {
                Image("action_close")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .hidden(self.search.isEmpty)
            
            Button {
                if self.search.isEmpty
                {
                    Toast.shared.show(text: "The request is empty")
                    return
                }
                
                self.hideKeyBoard()
                if !self.searchList.isEmpty
                {
                    self.searchList.removeAll()
                }
                self.startSearchAudio()
            } label: {
                Text("Find".uppercased())
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
            }
        })
        .background(Color("color_background"))
        .onAppear{
            if let info = UIUtils.getInfo()
            {
                self.token = info["token"] as! String
                self.secret = info["secret"] as! String
            }
        }
        .onTapGesture {
            self.hideKeyBoard()
        }
    }
    
    private func audioItem(bind: Binding<AudioStruct>) -> some View
    {
        let item = bind.wrappedValue
        return HStack(spacing: 0)
        {
            AudioThumbView()
                .padding(.horizontal, 15)
            
            VStack
            {
                Text(item.model.artist)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                Text("\(item.model.title) / \(item.model.duration.toTime())")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
            }
            
            Button {
                self.audioPlayer.addAudioToDB(model: item)
            } label: {
                Image("action_add")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
        .padding(.vertical, 10)
        .background(item.id == self.audioPlayer.playedModel?.id ? Color("color_playing") : Color("color_background"))
        .onTapGesture {
            self.playOrPause(item: item)
        }
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.id == self.audioPlayer.playedModel?.id
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.searchList)
        }
    }
    
    private func startSearchAudio()
    {
        self.searchAudio(count: self.searchMax, offset: self.searchOffset) { list in
            DispatchQueue.main.async {
                self.searchList.append(contentsOf: list)
            }
        }
    }
    
    private func searchAudio(count: Int, offset: Int, completionHandler: @escaping ((_ list: [AudioStruct]) -> Void))
    {
        let model = VKViewModel.shared
        model.refreshToken(token: self.token, secret: self.secret) { refresh in
            self.token = refresh.response.token
            self.secret = refresh.response.secret
            
            UIUtils.updateInfo(token: self.token, secret: self.secret)
            
            model.searchAudio(token: refresh.response.token,
                              secret: refresh.response.secret,
                              q: self.search, count: count, offset: offset) { list in
                completionHandler(list)
            }
        }
    }
    
    private func audioAppear(audio: AudioStruct)
    {
        if self.token.isEmpty || self.secret.isEmpty || self.search.isEmpty
        {
            return
        }
        
        if UIUtils.isPagination(list: self.searchList, audio: audio, offset: self.searchOffset)
        {
            let startIndex = self.searchList.endIndex + 1
            self.searchAudio(count: self.searchMax, offset: startIndex) { list in
                guard !list.isEmpty else { return }
                DispatchQueue.main.async {
                    self.searchList.append(contentsOf: list)
                }
            }
        }
    }
}
