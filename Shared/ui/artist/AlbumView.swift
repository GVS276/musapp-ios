//
//  AlbumView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.08.2022.
//

import SwiftUI

struct AlbumView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: AlbumViewModel
    
    private var albumId: String
    private var albumName: String
    private var artistName: String
    
    init(albumId: String, albumName: String, artistName: String, ownerId: Int, accessKey: String)
    {
        self.albumId = albumId
        self.albumName = albumName
        self.artistName = artistName
        self._model = StateObject(wrappedValue: AlbumViewModel(albumId: albumId, ownerId: ownerId, accessKey: accessKey))
    }
    
    var body: some View
    {
        ProfileHeaderView(title: self.albumName, subTitle: self.artistName) {
            if let image = ThumbCacheObj.cache[self.albumId] {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 150, maxHeight: 150)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 20, x: 0, y: 0)
            } else {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .frame(width: 150, height: 150)
            }
        } content: {
            VStack(spacing: 0)
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(30)
                    .removed(!self.model.isLoading)
                
                if !self.model.list.isEmpty
                {
                    ForEach(self.model.list, id: \.id) { item in
                        let playedId = self.audioPlayer.playedModel?.model.audioId
                        let isAddedAudio = self.audioPlayer.isAddedAudio(audioId: item.model.audioId)
                        let menuIconRes = isAddedAudio ? "action_finish" : "action_add"
                        
                        AudioAlbumItemView(item: item, playedId: playedId, menuIconRes: menuIconRes) { type in
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
                    }
                } else {
                    Text("No tracks")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .removed(self.model.isLoading)
                }
            }
            .padding(.vertical, 10)
            .background(Color("color_background"))
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
