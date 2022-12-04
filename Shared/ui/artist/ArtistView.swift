//
//  ArtistView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.08.2022.
//

import SwiftUI

struct ArtistView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: ArtistViewModel
    
    private var artistModel: ArtistModel
    
    init(artistModel: ArtistModel) {
        self.artistModel = artistModel
        self._model = StateObject(wrappedValue: ArtistViewModel(artistId: artistModel.id))
    }
    
    var body: some View
    {
        ProfileHeaderView(title: self.artistModel.name, subTitle: "")
        {
            Image("placeholder")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color("color_text"))
                .frame(width: 150, height: 150)
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
                    self.showItem(title: "Tracks") {
                        RootStack.shared.pushToView(view: ArtistTracksView(artistId: self.artistModel.id).environmentObject(self.audioPlayer))
                    }
                    
                    ForEach(self.model.audioList, id: \.id) { item in
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
                    }
                }
                
                if !self.model.albumList.isEmpty
                {
                    self.showItem(title: "Albums") {
                        RootStack.shared.pushToView(view: ArtistAlbumsView(artistId: self.artistModel.id, artistName: self.artistModel.name).environmentObject(self.audioPlayer))
                    }
                    
                    ForEach(self.model.albumList, id: \.id) { item in
                        AlbumItemView(item: item) {
                            RootStack.shared.pushToView(
                                view: AlbumView(albumId: item.albumId,
                                                albumName: item.title,
                                                artistName: self.artistModel.name,
                                                ownerId: item.ownerId,
                                                accessKey: item.accessKey).environmentObject(self.audioPlayer)
                            )
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
            self.audioPlayer.setPlayerList(list: self.model.audioList)
        }
    }
    
    private func showItem(title: String, clicked: @escaping () -> Void) -> some View
    {
        Button {
            clicked()
        } label: {
            Text(title)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 18))
                .underline()
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
        }
    }
}
