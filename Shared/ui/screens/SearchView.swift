//
//  SearchView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import SwiftUI

fileprivate class SearchViewModel: ObservableObject
{
    @Published var list = [AudioStruct]()
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var query: String = ""
    
    private var isRequest = true
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    func startReceiveAudio(q: String)
    {
        self.query = q
        self.list.removeAll()
        self.receiveAudio(count: 50, offset: 0)
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
                    print("Problems with the Internet")
                case .ErrorRequest:
                    print("An error occurred when accessing the server")
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
            
            self.model.searchAudio(token: self.token,
                                   secret: self.secret,
                                   q: self.query, count: count, offset: offset) { list, result in
                DispatchQueue.main.async {
                    switch result {
                    case .ErrorInternet:
                        print("Problems with the Internet")
                    case .ErrorRequest:
                        print("An error occurred while accessing the list")
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

struct SearchView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model = SearchViewModel()
    @State private var search = ""
    
    var body: some View
    {
        StackView(title: "", back: true)
        {
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
            SearchTextField(text: self.$search, onClickReturn: {
                self.model.startReceiveAudio(q: self.search)
            }).onTapGesture {}
            
            Button {
                self.search.removeAll()
            } label: {
                Image("action_close")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .removed(self.search.isEmpty)
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
            self.audioPlayer.setPlayerList(list: self.model.list)
        }
    }
}
