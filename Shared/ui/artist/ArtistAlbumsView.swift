//
//  ArtistAlbumsView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct ArtistAlbumsView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model: ArtistAlbumsViewModel
    
    private var artistName: String
    
    init(artistId: String, artistName: String) {
        self.artistName = artistName
        self._model = StateObject(wrappedValue: ArtistAlbumsViewModel(artistId: artistId))
    }
    
    var body: some View
    {
        StackView(title: "All albums", back: true)
        {
            if self.model.isRequestStatus == .Receiving && self.model.list.isEmpty
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.vertical, 20)
            }
            
            if self.model.isRequestStatus == .Empty
            {
                Text("No albums")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list, id: \.id) { item in
                        AlbumItemView(item: item) {
                            RootStack.shared.pushToView(
                                view: AlbumView(albumId: item.albumId,
                                                albumName: item.title,
                                                artistName: self.artistName,
                                                ownerId: item.ownerId,
                                                accessKey: item.accessKey).environmentObject(self.audioPlayer)
                            )
                        }
                        .id(item.id)
                        .onAppear {
                            if item.id == self.model.list.last?.id && self.model.isAllowLoading
                            {
                                let end = self.model.list.endIndex
                                self.model.receiveAlbums(offset: end)
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
