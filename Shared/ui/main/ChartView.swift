//
//  ChartView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 04.12.2022.
//

import SwiftUI

struct ChartView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model = ChartViewModel()
    
    var body: some View
    {
        StackView(title: "Chart", back: false)
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
            
            ScrollView(.vertical, showsIndicators: false)
            {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list.indices, id: \.self) { index in
                        
                        let block = self.model.list[index]
                        
                        if block.dataType == "catalog_banners"
                        {
                            ItemsSectionBannerView(block: block) { playlistId, ownerId, accessKey in
                                RootStack.shared.pushToView(
                                    view: PlaylistView(playlistId: playlistId,
                                                       ownerId: ownerId,
                                                       accessKey: accessKey)
                                        .environmentObject(audioPlayer)
                                )
                            }
                        }
                        
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
                        
                        if block.dataType == "music_playlists"
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
                        
                    }
                }
                .padding(.vertical, 10)
            }
            
        } menu: {
            Button {
                model.refresh()
            } label: {
                Image("action_refresh")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        }
    }
}
