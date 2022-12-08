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
                    }
                    
                    ForEach(model.list, id: \.id) { item in
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
            self.audioPlayer.setPlayerList(list: model.list)
        }
    }
    
    private func goToNewSongs()
    {
        RootStack.shared.pushToView(
            view: NewSongsView(sectionId: model.idNewSongs).environmentObject(audioPlayer))
    }
}
