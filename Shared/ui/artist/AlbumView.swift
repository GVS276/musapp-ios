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
                Image(uiImage: image.imageWith(newSize: CGSize(width: 150, height: 150)))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image("album")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .frame(width: 150, height: 150)
            }
        } content: {
            VStack(spacing: 0)
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
                
                if self.model.isRequestStatus == .Received
                {
                    ForEach(self.model.list, id: \.id) { item in
                        let playedId = self.audioPlayer.playedModel?.audioId
                        
                        AudioItemView(item: item, source: .AudioFromAlbum, playedId: playedId) { type in
                            switch type {
                            case .Menu:
                                MenuDialog.shared.showMenu(audio: item)
                            case .Item:
                                self.playOrPause(item: item)
                            }
                        }
                        .id(item.id)
                    }
                }
            }
            .padding(.vertical, 10)
        } menu: {
            EmptyView()
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
