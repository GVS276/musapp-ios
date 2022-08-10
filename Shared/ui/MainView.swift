//
//  MainView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct MainView: View
{
    @EnvironmentObject var audioPlayer: AudioPlayerModelView
    
    private func modelBinding(_ item: AudioStruct) -> Binding<AudioStruct>? {
        guard let index = self.audioPlayer.audioList.firstIndex(where: { $0.id == item.id }) else { return nil }
        return .init(get: { self.audioPlayer.audioList[index] },
                     set: { self.audioPlayer.audioList[index] = $0 })
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.audioPlayer.audioList, id: \.id) { item in
                        self.modelBinding(item).map { bind in
                            self.audioItem(bind: bind).id(item.id)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .viewTitle("Music", leading: HStack {
            Button {
                UINavigation.pushToView(view: SearchView().environmentObject(self.audioPlayer))
            } label: {
                Image("action_search")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        } , trailing: HStack {
            Button {
                
            } label: {
                Image("action_settings")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        })
    }
    
    
    private func audioItem(bind: Binding<AudioStruct>) -> some View
    {
        let item = bind.wrappedValue
        return HStack(spacing: 0)
        {
            AudioThumbView()
                .padding(.horizontal, 15)
            
            VStack
            {
                Text(item.model.artist)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                HStack
                {
                    Text(item.model.title)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(UIUtils.getTimeFromDuration(sec: Int(item.model.duration)))
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                }
            }
            .padding(.trailing, 15)
        }
        .padding(.vertical, 10)
        .background(item.isPlaying ? Color("color_playing") : Color("color_background"))
        .onTapGesture {
            self.playOrPause(bind: bind)
        }
    }
    
    private func playOrPause(bind: Binding<AudioStruct>)
    {
        let item = bind.wrappedValue
        if item.id == self.audioPlayer.playedId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(url: item.model.streamUrl, playedId: item.id, mode: .FromMain)
        }
    }
}
