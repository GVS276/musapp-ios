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
    @StateObject private var model = SearchViewModel()
    @State private var search = ""
    
    var body: some View
    {
        StackView(title: "", back: false)
        {
            if self.model.isRequestStatus == .Receiving && self.model.list.isEmpty
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.vertical, 20)
            }
            
            if self.model.isRequestStatus == .Empty
            {
                Text("No tracks")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list, id:\.id) { item in
                        let playedId = self.audioPlayer.playedModel?.audioId
                        
                        AudioItemView(item: item, source: .OtherAudio, playedId: playedId) { type in
                            switch type {
                            case .Menu:
                                MenuDialog.shared.showMenu(audio: item)
                            case .Item:
                                self.playOrPause(item: item)
                            }
                        }
                        .id(item.id)
                        .onAppear {
                            if item.id == self.model.list.last?.id && self.model.isAllowLoading
                            {
                                let end = self.model.list.endIndex
                                self.model.receiveAudio(offset: end)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        } menu: {
            SearchTextField(text: self.$search) {
                self.model.startReceiveAudio(q: self.search)
            }
            .placeholder(shouldShow: self.search.isEmpty, title: "Search...", paddingHorizontal: 0)
            .onTapGesture {}
            
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
    
    private func playOrPause(item: AudioModel)
    {
        if item.audioId == self.audioPlayer.playedModel?.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.model.list)
        }
    }
}
