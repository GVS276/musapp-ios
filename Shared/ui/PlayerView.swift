//
//  PlayerView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct PlayerView: View
{
    @EnvironmentObject var audioPlayer: AudioPlayerModelView
    
    @State private var currentTime: Float = .zero
    @State private var repeatAudio = false
    @State private var randomAudio = false
    @State private var touchedSlider = false
    
    var body: some View
    {
        VStack(spacing: 10)
        {
            Image("subtract")
                .renderingMode(.template)
                .foregroundColor(Color("color_text"))
                .padding(.top, 20)
            
            ThumbView(url: self.audioPlayer.playedModel?.model.thumb ?? "",
                      albumId: self.audioPlayer.playedModel?.model.albumId ?? "",
                      big: true)
                .padding(.top, 10)
            
            Text(self.audioPlayer.playedModel?.model.artist ?? "Artist")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            HStack(spacing: 5)
            {
                Image("action_explicit")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .frame(width: 14, height: 14)
                    .removed(!(self.audioPlayer.playedModel?.model.isExplicit ?? false))
                
                Text(self.audioPlayer.playedModel?.model.title ?? "Title")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            AudioSliderView(value: self.currentTime,
                            maxValue: Float(self.audioPlayer.playedModel?.model.duration ?? 0),
                            touchedHandler: { touched, currentValue in
                if !touched {
                    self.audioPlayer.seek(value: currentValue)
                    self.audioPlayer.play()
                } else {
                    if self.audioPlayer.audioPlaying {
                        self.audioPlayer.pause()
                    }
                    self.currentTime = currentValue
                }
                self.touchedSlider = touched
            })
            
            HStack
            {
                Text(self.currentTime.toTime())
                    .foregroundColor(self.touchedSlider ? .blue : Color("color_text"))
                    .font(.system(size: 14))
                
                Spacer()
                
                Text(self.audioPlayer.playedModel?.model.duration.toTime() ?? "--")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
            }
            .padding(.bottom, 10)
            
            HStack(spacing: 0)
            {
                Button {
                    self.randomAudio.toggle()
                    self.audioPlayer.randomAudio(value: self.randomAudio)
                } label: {
                    Image("random")
                        .renderingMode(.template)
                        .foregroundColor(self.randomAudio ? .blue : .secondary)
                }
                
                Spacer()
                
                Button {
                    self.audioPlayer.control(tag: .Previous)
                } label: {
                    Image("previous")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                
                Button {
                    self.audioPlayer.control(tag: .PlayOrPause)
                } label: {
                    Image(self.audioPlayer.audioPlaying ? "pause" : "play")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color("color_text"))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 20)
                
                Button {
                    self.audioPlayer.control(tag: .Next)
                } label: {
                    Image("next")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                
                Spacer()
                
                Button {
                    self.repeatAudio.toggle()
                    self.audioPlayer.repeatAudio(value: self.repeatAudio)
                } label: {
                    Image("repeat")
                        .renderingMode(.template)
                        .foregroundColor(self.repeatAudio ? .blue : .secondary)
                }
            }
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 30)
        .background(Color("color_background"))
        .onAppear(perform: {
            self.repeatAudio = self.audioPlayer.isRepeatAudio()
            self.randomAudio = self.audioPlayer.isRandomAudio()
            self.initTimer()
        })
        .onDisappear {
            self.audioPlayer.removeCurrentTime()
        }
    }
    
    private func initTimer()
    {
        self.currentTime = self.audioPlayer.currentTime()
        self.audioPlayer.initCurrentTime { current in
            self.currentTime = current
        }
    }
}
