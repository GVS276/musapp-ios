//
//  ArtistTracksView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct ArtistTracksView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: ArtistTracksViewModel
    
    private var artistId: String
    init(artistId: String) {
        self.artistId = artistId
        self._model = StateObject(wrappedValue: ArtistTracksViewModel(artistId: artistId))
    }
    
    var body: some View
    {
        StackView(title: "All tracks", back: true) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding(30)
                .removed(!self.model.list.isEmpty)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list, id:\.id) { item in
                        let isAddedAudio = self.audioPlayer.isAddedAudio(audioId: item.model.audioId)
                        AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId,
                                      menuIconRes: isAddedAudio ? "action_finish" : "action_add") { type in
                            switch type {
                            case .Menu:
                                if isAddedAudio {
                                    self.audioPlayer.deleteAudioFromDB(audioId: item.model.audioId)
                                } else {
                                    self.audioPlayer.addAudioToDB(model: item)
                                }
                            case .Item:
                                self.playOrPause(item: item)
                            }
                        }
                        .id(item.id)
                        .onAppear {
                            if item.id == self.model.list.last?.id && self.model.list.count >= 50 && self.model.isLoading
                            {
                                let end = self.model.list.endIndex
                                self.model.receiveAudio(artistId: self.artistId, count: 50, offset: end)
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