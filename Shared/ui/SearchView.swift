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
    private var searchOffset = 0
    
    var body: some View
    {
        VStack
        {
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
        self.searchAudio(count: self.searchMax, offset: self.searchOffset) { list in
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
                    
                    model.searchAudio(token: refresh.response.token,
                                      secret: refresh.response.secret,
                                      q: self.search, count: count, offset: offset) { list, listResult in
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
        if self.token.isEmpty || self.secret.isEmpty || self.search.isEmpty
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
