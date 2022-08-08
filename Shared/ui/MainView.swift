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
    @EnvironmentObject var mainModel: MainViewModel
    
    @State private var audioList: [AudioStruct] = []
    @State private var audioPlaying = false
    @State private var audioPlayerReady = false
    
    private func modelBinding(_ item: AudioStruct) -> Binding<AudioStruct>? {
        guard let index = self.audioList.firstIndex(where: { $0.id == item.id }) else { return nil }
        return .init(get: { self.audioList[index] },
                     set: { self.audioList[index] = $0 })
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    ForEach(self.audioList, id: \.id) { item in
                        self.modelBinding(item).map { bind in
                            self.audioItem(bind: bind).id(item.id)
                        }
                    }
                }
            }
            
            self.miniPlayer()
                .removed(!self.audioPlayerReady)
        }
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .viewTitle("Music", leading: HStack {
            Button {
                
            } label: {
                Image("action_search")
            }
        } , trailing: HStack {
            Button {
                
            } label: {
                Image("action_settings")
            }
        })
        .onAppear {
            self.mainModel.receiveAudioList { list in
                self.audioList = list
            }
            self.audioPlayer.addObserver { ready in
                self.audioPlayerReady = ready
            } finishedHandler: {
                print("finished")
                self.audioTrackFinished()
            } playingHandler: { playing, id in
                self.audioPlaying = playing
                self.setPlaying(id: id, value: playing)
            } controlHandler: { tag in
                if tag == .Next {
                    self.audioTrackNext()
                }
                else if tag == .Previous {
                    self.audioTrackPrevious()
                }
            }
        }
    }
    
    private func playedTrack() -> some View
    {
        ZStack
        {
            Color.blue.frame(maxWidth: .infinity, maxHeight: .infinity)
            Image("play")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
    }
    
    private func audioItem(bind: Binding<AudioStruct>) -> some View
    {
        let item = bind.wrappedValue
        return HStack(spacing: 0)
        {
            ZStack
            {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(10)
            }
            .background(Color.gray)
            .overlay(self.playedTrack().removed(!item.isPlaying))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
            VStack
            {
                Text(item.model.artist)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                HStack
                {
                    Text(item.model.title)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(UIUtils.getTimeFromDuration(sec: Int(item.model.duration)))
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .lineLimit(1)
                }
            }
            .padding(.trailing, 15)
        }
        .padding(.top, 15)
        .onTapGesture {
            self.playOrPause(bind: bind)
        }
    }
        
    private func miniPlayer() -> some View
    {
        HStack(spacing: 0) {
            ZStack
            {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(10)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
            VStack
            {
                Text(self.currentAudio()?.model.artist ?? "Artist")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                Text(self.currentAudio()?.model.title ?? "Title")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
            }
            .padding(.trailing, 15)
            
            Button {
                self.playOrPause()
            } label: {
                Image(self.audioPlaying ? "pause" : "play")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)
            .padding(15)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color("color_toolbar").edgesIgnoringSafeArea(.bottom))
        .onTapGesture {
            withAnimation {
                self.audioPlayer.playerMode = .FULL
            }
        }
    }
    
    private func currentAudio() -> AudioStruct?
    {
        if self.audioPlayer.playedId.isEmpty
        {
            return nil
        }
        
        if let index = self.audioList.firstIndex(where: {$0.id == self.audioPlayer.playedId})
        {
            return self.audioList[index]
        }
        
        return nil
    }
    
    private func oldTrackStopped()
    {
        if self.audioPlayer.playedId.isEmpty
        {
            return
        }
        
        if let index = self.audioList.firstIndex(where: {$0.id == self.audioPlayer.playedId})
        {
            self.audioList[index].isPlaying = false
        }
    }
    
    private func setPlaying(id: String, value: Bool)
    {
        if let index = self.audioList.firstIndex(where: {$0.id == id})
        {
            self.audioList[index].isPlaying = value
            self.audioPlayer.playedModel = self.audioList[index]
        }
    }
    
    private func playOrPause()
    {
        if self.audioPlaying {
            self.audioPlayer.pause()
        } else {
            self.audioPlayer.play()
        }
    }
    
    private func playOrPause(bind: Binding<AudioStruct>)
    {
        let item = bind.wrappedValue
        if item.id == self.audioPlayer.playedId
        {
            self.playOrPause()
        } else {
            self.oldTrackStopped()
            self.audioPlayer.startStream(url: item.model.streamUrl, playedId: item.id)
        }
    }
    
    private func audioTrackFinished()
    {
        if let index = self.audioList.firstIndex(where: {$0.id == self.audioPlayer.playedId}) {
            let next = index + 1
            if next > self.audioList.count - 1
            {
                self.oldTrackStopped()
                self.audioPlayer.stop()
            } else {
                let audio = self.audioList[next]
                self.oldTrackStopped()
                self.audioPlayer.startStream(url: audio.model.streamUrl, playedId: audio.id)
            }
        }
    }
    
    private func audioTrackNext()
    {
        if let index = self.audioList.firstIndex(where: {$0.id == self.audioPlayer.playedId}) {
            let next = index + 1 > self.audioList.count - 1 ? 0 : index + 1
            let audio = self.audioList[next]
            self.oldTrackStopped()
            self.audioPlayer.startStream(url: audio.model.streamUrl, playedId: audio.id)
        }
    }
    
    private func audioTrackPrevious()
    {
        if let index = self.audioList.firstIndex(where: {$0.id == self.audioPlayer.playedId}) {
            let previous = index - 1 < 0 ? self.audioList.count - 1 : index - 1
            let audio = self.audioList[previous]
            self.oldTrackStopped()
            self.audioPlayer.startStream(url: audio.model.streamUrl, playedId: audio.id)
        }
    }
}
