//
//  LibraryView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 04.12.2022.
//

import SwiftUI

struct LibraryView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    @State private var search = ""
    
    var body: some View
    {
        StackView(title: "Library", back: false)
        {
            if self.audioPlayer.audioList.isEmpty
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
                    ForEach(self.audioPlayer.audioList, id: \.id) { item in
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
            Button {
                
            } label: {
                Image("action_settings")
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
            self.audioPlayer.setPlayerList(list: self.audioPlayer.audioList)
        }
    }
}
