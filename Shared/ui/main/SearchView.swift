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
        StackView(title: "Search", back: false)
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    
                    findSector()
                    
                    if model.isRequestStatus == .None {
                        
                        suggestionsSector()
                        
                    } else {
                        
                        searchSector()
                        
                    }
                    
                }
                .padding(.vertical, 10)
            }
        } menu: {
            EmptyView()
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
    
    private func searchSector() -> some View
    {
        ForEach(model.list, id:\.id) { item in
            let playedId = audioPlayer.playedModel?.audioId
            
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
                if item.id == model.list.last?.id && model.isAllowLoading
                {
                    let end = model.list.endIndex
                    model.receiveAudio(offset: end)
                }
            }
        }
    }
    
    private func suggestionsSector() -> some View
    {
        ForEach(model.listSuggestion.indices, id:\.self) { index in
            
            let item = model.listSuggestion[index]
            
            Text(item.title ?? "")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("color_text"))
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .onTapGesture {
                    
                    guard let q = item.title else { return }
                    
                    search = q
                    
                    hideKeyBoard()
                    
                    model.startReceiveAudio(q: search)
                    
                }
            
        }
    }
    
    private func findSector() -> some View
    {
        VStack(spacing: 20)
        {
            HStack(spacing: 10)
            {
                SearchTextField(text: $search) {
                    
                    hideKeyBoard()
                    
                    model.startReceiveAudio(q: search)
                    
                }
                .frame(height: 36)
                .placeholder(shouldShow: search.isEmpty, title: "Find tracks...", paddingHorizontal: 0)
                .onTapGesture {}
                
                Button {
                    search.removeAll()
                    model.clearSearch()
                } label: {
                    Image("action_close")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                .removed(search.isEmpty)
            }
            .padding(.horizontal, 10)
            .background(Color("color_toolbar"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if model.isRequestStatus == .Receiving && model.list.isEmpty
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if model.isRequestStatus == .Empty
            {
                Text("No tracks")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }
}
