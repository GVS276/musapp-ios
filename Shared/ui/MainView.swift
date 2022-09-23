//
//  MainView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct MainView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    var body: some View
    {
        StackView(title: "Library", back: false)
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.audioPlayer.audioList, id: \.id) { item in
                        let playedId = self.audioPlayer.playedModel?.model.audioId
                        
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
                RootStack.shared.pushToView(view: MyMusicView().environmentObject(self.audioPlayer))
            } label: {
                Image("action_my")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .frame(width: 20, height: 20)
            }
            
            Button {
                RootStack.shared.pushToView(view: SearchView().environmentObject(self.audioPlayer))
            } label: {
                Image("action_search")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            
            Button {
                RootStack.shared.pushToView(view: AboutView())
            } label: {
                Image("action_settings")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        }
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.model.audioId == self.audioPlayer.playedModel?.model.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.audioPlayer.audioList)
        }
    }
}
