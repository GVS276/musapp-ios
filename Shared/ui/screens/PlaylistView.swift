//
//  PlaylistView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct PlaylistView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: PlaylistViewModel
    
    init(playlistId: String, ownerId: String, accessKey: String)
    {
        self._model = StateObject(wrappedValue: PlaylistViewModel(
            playlistId: playlistId, ownerId: ownerId, accessKey: accessKey))
    }
    
    var body: some View
    {
        StackView(title: "Playlist", back: true) {
            if model.isRequestStatus == .Receiving && self.model.list.isEmpty
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.vertical, 20)
            }
            
            if model.isRequestStatus == .Empty
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
                    ForEach(model.list, id:\.id) { item in
                        let playedId = audioPlayer.playedModel?.audioId
                        
                        AudioItemView(item: item, source: .OtherAudio, playedId: playedId) { type in
                            switch type {
                            case .Menu:
                                MenuDialog.shared.showMenu(audio: item)
                            case .Item:
                                playOrPause(item: item)
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
                .padding(.vertical, 10)
            }
        } menu: {
            EmptyView()
        }
    }
    
    private func playOrPause(item: AudioModel)
    {
        if item.audioId == audioPlayer.playedModel?.audioId
        {
            audioPlayer.control(tag: .PlayOrPause)
        } else {
            audioPlayer.startStream(model: item)
            audioPlayer.setPlayerList(list: model.list)
        }
    }
}
