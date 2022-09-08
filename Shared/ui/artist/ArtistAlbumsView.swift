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
    
    private var artistId: String
    private var artistName: String
    
    init(artistId: String, artistName: String) {
        self.artistId = artistId
        self.artistName = artistName
        self._model = StateObject(wrappedValue: ArtistAlbumsViewModel(artistId: artistId))
    }
    
    var body: some View
    {
        StackView(title: "All albums", back: true) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding(30)
                .removed(!self.model.list.isEmpty)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.model.list, id: \.id) { item in
                        self.albumItem(item: item)
                            .id(item.id)
                            .onAppear {
                                if item.id == self.model.list.last?.id && self.model.list.count >= 50 && self.model.isLoading
                                {
                                    let end = self.model.list.endIndex
                                    self.model.receiveAlbums(artistId: self.artistId, count: 50, offset: end)
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
    
    private func albumItem(item: AlbumModel) -> some View
    {
        Button {
            RootStack.shared.pushToView(view:AlbumView(albumId: item.albumId,
                                                       albumName: item.title,
                                                       artistName: self.artistName,
                                                       ownerId: item.ownerId,
                                                       accessKey: item.accessKey).environmentObject(self.audioPlayer))
        } label: {
            HStack(spacing: 15)
            {
                ThumbView(url: item.thumb, albumId: item.albumId, big: false)
                
                VStack
                {
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    let strYear = String(item.year)
                    let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                    
                    Text("\(strYear) • \(strCount)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
    }
}
