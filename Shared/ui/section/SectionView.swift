//
//  SectionView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import SwiftUI

struct SectionView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: SectionViewModel
    
    private let title: String
    
    init(sectionId: String, title: String)
    {
        self.title = title
        self._model = StateObject(wrappedValue: SectionViewModel(id: sectionId))
    }
    
    var body: some View
    {
        StackView(title: title, back: true)
        {
            if self.model.isRequestStatus == .Receiving
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
                    ForEach(self.model.list.indices, id: \.self) { index in
                        
                        let block = self.model.list[index]
                        
                        if block.layout?.name == "header"
                        {
                            createHeader(block: block)
                        }
                        
                        if block.dataType == "music_audios"
                        {
                            createAudiosView(block: block)
                        }
                        
                        if block.dataType == "music_playlists", block.layout?.name == "list"
                        {
                            createListPlaylistsView(block: block)
                        }
                        
                        if block.dataType == "music_playlists", block.layout?.name == "large_slider"
                        {
                            createLargePlaylistsView(block: block)
                        }
                        
                    }
                }
                .padding(.vertical, 10)
            }
        } menu: {
            EmptyView()
        }
    }
    
    private func createAudiosView(block: SectionBlock) -> some View
    {
        ForEach(block.audios.indices, id: \.self) { index in
            
            let item = block.audios[index]
            let playedId = audioPlayer.playedModel?.audioId
            
            AudioItemView(item: item, source: .OtherAudio, playedId: playedId) { type in
                switch type {
                case .Menu:
                    MenuDialog.shared.showMenu(audio: item)
                case .Item:
                    
                    if item.audioId == self.audioPlayer.playedModel?.audioId
                    {
                        self.audioPlayer.control(tag: .PlayOrPause)
                    } else {
                        self.audioPlayer.startStream(model: item)
                        self.audioPlayer.setPlayerList(list: block.audios)
                    }
                    
                }
            }
        }
    }
    
    private func createListPlaylistsView(block: SectionBlock) -> some View
    {
        ForEach(block.playlists.indices, id: \.self) { index in
            
            let item = block.playlists[index]
            
            PlaylistItemView(item: item, large: false) {
                /*RootStack.shared.pushToView(
                    view: AlbumView(albumId: item.albumId,
                                    albumName: item.title,
                                    artistName: item.description,
                                    ownerId: item.ownerId,
                                    accessKey: item.accessKey).environmentObject(self.audioPlayer)
                )*/
            }
        }
    }
    
    private func createLargePlaylistsView(block: SectionBlock) -> some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(block.playlists.indices, id: \.self) { index in
                    
                    let item = block.playlists[index]
                    
                    PlaylistItemView(item: item, large: true) {
                        /*RootStack.shared.pushToView(
                            view: AlbumView(albumId: item.albumId,
                                            albumName: item.title,
                                            artistName: item.description,
                                            ownerId: item.ownerId,
                                            accessKey: item.accessKey).environmentObject(self.audioPlayer)
                        )*/
                    }
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    private func createHeader(block: SectionBlock) -> some View
    {
        HStack(spacing: 15)
        {
            Text(block.layout?.title ?? "Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
            
            if !block.buttons.isEmpty
            {
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            if let last = block.buttons.last
            {
                let id = last.sectionId ?? ""
                let text = block.layout?.title ?? "Title"
                
                RootStack.shared.pushToView(
                    view: SectionView(sectionId: id, title: text).environmentObject(audioPlayer))
            }
        }
    }
}
