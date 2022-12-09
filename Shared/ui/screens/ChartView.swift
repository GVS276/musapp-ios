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
                    if self.model.isRequestStatus == .Received
                    {
                        bannersView()
                        
                        Button {
                            goToNewSongs()
                        } label: {
                            HStack(spacing: 15)
                            {
                                Text("New songs")
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
                    
                    GridScrollStack(rows: 3, count: model.listAudio.count) { index in
                        
                        let item = model.listAudio[index]
                        let playedId = audioPlayer.playedModel?.audioId
                        
                        AudioItemView(item: item, source: .OtherAudio, playedId: playedId) { type in
                            switch type {
                            case .Menu:
                                MenuDialog.shared.showMenu(audio: item)
                            case .Item:
                                self.playOrPause(item: item)
                            }
                        }
                        .frame(minWidth: 250, idealWidth: 250, maxWidth: 250)
                        
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
    
    private func playOrPause(item: AudioModel)
    {
        if item.audioId == self.audioPlayer.playedModel?.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: model.listAudio)
        }
    }
    
    private func goToNewSongs()
    {
        RootStack.shared.pushToView(
            view: NewSongsView(sectionId: model.idNewSongs).environmentObject(audioPlayer))
    }
    
    private func bannersView() -> some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(model.listBanner, id: \.id) { item in
                    createBanner(item: item)
                }
            }
            .padding(.horizontal, 5)
        }
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
                    
                    RootStack.shared.pushToView(
                        view: AlbumView(albumId: albumId,
                                        albumName: item.text ?? "",
                                        artistName: item.title ?? "",
                                        ownerId: Int(ownerId) ?? 0,
                                        accessKey: accessKey).environmentObject(self.audioPlayer)
                    )
                }
            }
        }
    }
}
