//
//  MyMusicView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 19.08.2022.
//

import SwiftUI

struct MyMusicView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model = MyMusicViewModel()
    
    var body: some View
    {
        StackView(title: "My music", back: true)
        {
            if self.model.isRequestStatus == .Empty
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
                    self.createItem(iconSet: "playlist", title: "Playlists") {
                        RootStack.shared.pushToView(view: PlaylistsView().environmentObject(self.audioPlayer))
                    }
                    
                    if self.model.isRequestStatus == .Receiving && self.model.list.isEmpty
                    {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.vertical, 20)
                    }
                    
                    ForEach(self.model.list, id:\.id) { item in
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
                        .onAppear {
                            if item.id == self.model.list.last?.id && self.model.isAllowLoading
                            {
                                let end = self.model.list.endIndex
                                self.model.receiveAudio(offset: end)
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
        if item.audioId == self.audioPlayer.playedModel?.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.model.list)
        }
    }
    
    private func createItem(iconSet: String, title: String, clicked: @escaping () -> Void) -> some View
    {
        Button {
            clicked()
        } label: {
            HStack(spacing: 15)
            {
                Image(iconSet)
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(Color("color_thumb"))
                    .clipShape(Circle())
                
                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }
            .padding(.leading, 15)
            .padding(.vertical, 10)
        }
    }
}
