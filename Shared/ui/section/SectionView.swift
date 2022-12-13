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
                            ItemsSectionHeaderView(block: block) { sectionId, title in
                                
                                RootStack.shared.pushToView(
                                    view: SectionView(sectionId: sectionId, title: title)
                                        .environmentObject(audioPlayer))
                            }
                        }
                        
                        if block.dataType == "music_audios"
                        {
                            ItemsSectionAudioView(block: block) { audio in
                                
                                if audio.audioId == audioPlayer.playedModel?.audioId
                                {
                                    audioPlayer.control(tag: .PlayOrPause)
                                } else {
                                    audioPlayer.startStream(model: audio)
                                    audioPlayer.setPlayerList(list: block.audios)
                                }
                            }
                        }
                        
                        if block.dataType == "music_playlists", block.layout?.name == "list"
                        {
                            ItemsSectionPlaylistView(block: block, vertical: true) { playlist in
                                RootStack.shared.pushToView(
                                    view: PlaylistView(playlistId: playlist.albumId,
                                                       ownerId: String(playlist.ownerId),
                                                       accessKey: playlist.accessKey)
                                        .environmentObject(audioPlayer)
                                )
                            }
                        }
                        
                        if block.dataType == "music_playlists", block.layout?.name == "large_slider"
                        {
                            ItemsSectionPlaylistView(block: block, vertical: false) { playlist in
                                RootStack.shared.pushToView(
                                    view: PlaylistView(playlistId: playlist.albumId,
                                                       ownerId: String(playlist.ownerId),
                                                       accessKey: playlist.accessKey)
                                        .environmentObject(audioPlayer)
                                )
                            }
                        }
                        
                        if block.dataType == "artist_videos"
                        {
                            Text("Скоро")
                                .foregroundColor(Color("color_text"))
                                .font(.system(size: 16))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                        }
                        
                        if block.dataType == "links", block.layout?.name == "list"
                        {
                            ItemsSectionLinkView(block: block, vertical: true) { artistDomain in
                                
                            }
                        }
                        
                        if block.dataType == "links", block.layout?.name == "slider"
                        {
                            ItemsSectionLinkView(block: block, vertical: false) { artistDomain in
                                RootStack.shared.pushToView(
                                    view: SectionArtistView(artistDomain: artistDomain)
                                        .environmentObject(audioPlayer)
                                )
                            }
                        }
                        
                    }
                }
                .padding(.vertical, 10)
            }
        } menu: {
            EmptyView()
        }
    }
}
