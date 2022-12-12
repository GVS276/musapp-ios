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
                            createBannersView(block: block)
                        }
                        
                        if block.layout?.name == "header"
                        {
                            createHeader(block: block)
                        }
                        
                        if block.dataType == "music_audios"
                        {
                            createAudiosView(block: block)
                        }
                        
                        if block.dataType == "music_playlists"
                        {
                            createPlaylistsView(block: block)
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
    
    private func createBannersView(block: SectionBlock) -> some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(block.banners, id: \.id) { item in
                    createBanner(item: item)
                }
            }
            .padding(.horizontal, 5)
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
    
    private func createPlaylistsView(block: SectionBlock) -> some View
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
        Button {
            if let last = block.buttons.last
            {
                let id = last.sectionId ?? ""
                let text = block.layout?.title ?? "Title"
                
                RootStack.shared.pushToView(
                    view: SectionView(sectionId: id, title: text).environmentObject(audioPlayer))
            }
        } label: {
            HStack(spacing: 15)
            {
                Text(block.layout?.title ?? "Title")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
        .padding(.top, 20)
    }
    
    private func createBanner(item: CatalogBanner) -> some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            ThumbBannerView(url: item.image ?? "", bannerId: String(item.id ?? 0))
            
            Text(item.title ?? "Title")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(2)
                .padding(.top, 10)
            
            Text(item.text ?? "Text")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(2)
                .padding(.top, 2)
            
            Text(item.subtext ?? "Subtext")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(2)
                .padding(.top, 2)
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300,
               minHeight: 150, idealHeight: nil, maxHeight: 300,
               alignment: .topLeading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .onTapGesture {
            
            if let url = item.url {
                
                if let last = url.split(separator: "/").last {
                    
                    let inf = last.split(separator: "_")
                    
                    guard inf.count == 3 else {
                        return
                    }
                    
                    let ownerId = String(inf[0])
                    let albumId = String(inf[1])
                    let accessKey = String(inf[2])
                    
                    /*RootStack.shared.pushToView(
                        view: AlbumView(albumId: albumId,
                                        albumName: item.text ?? "",
                                        artistName: item.title ?? "",
                                        ownerId: Int(ownerId) ?? 0,
                                        accessKey: accessKey).environmentObject(self.audioPlayer)
                    )*/
                }
            }
        }
    }
}
