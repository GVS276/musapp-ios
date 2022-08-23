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
        VStack(spacing: 0)
        {
            Button {
                self.audioPlayer.playerSheet = false
            } label: {
                Image("action_down")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(15)
            }
            
            ThumbView(url: self.audioPlayer.playedModel?.model.thumb ?? "",
                      albumId: self.audioPlayer.playedModel?.model.albumId ?? "",
                      big: true)
                .padding(30)
            
            Spacer()
            
            HStack(spacing: 20)
            {
                VStack
                {
                    HStack(spacing: 10)
                    {
                        Text(self.audioPlayer.playedModel?.model.artist ?? "Artist")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 18))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        
                        Text("E")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 11))
                            .padding(.horizontal, 3)
                            .border(Color("color_text"))
                            .removed(!(self.audioPlayer.playedModel?.model.isExplicit ?? false))
                        
                        Spacer()
                    }
                    
                    Text(self.audioPlayer.playedModel?.model.title ?? "Title")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .onlyLeading()
                }
                
                Spacer()
                
                Menu {
                    Button {
                        
                    } label: {
                        Text("Добавить")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Перейти к артисту")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Перейти к альбому")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                    }
                } label: {
                    Image("action_menu")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .padding(5)
                        .background(Color("color_toolbar"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            
            HStack(spacing: 0)
            {
                Button {
                    self.randomAudio.toggle()
                    self.audioPlayer.randomAudio(value: self.randomAudio)
                } label: {
                    Image("random")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(self.randomAudio ? .blue : Color("color_text"))
                        
                }
                .frame(width: 30, height: 30)
                
                Spacer()
                
                Button {
                    self.repeatAudio.toggle()
                    self.audioPlayer.repeatAudio(value: self.repeatAudio)
                } label: {
                    Image("repeat")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(self.repeatAudio ? .blue : Color("color_text"))
                        
                }
                .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            
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
                .padding(.bottom, 10)
                .padding(.horizontal, 30)
            
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
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
            
            HStack(spacing: 60)
            {
                Button {
                    self.audioPlayer.control(tag: .Previous)
                } label: {
                    Image("previous")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color("color_text"))
                        
                }
                .frame(width: 35, height: 35)
                
                Button {
                    self.audioPlayer.control(tag: .PlayOrPause)
                } label: {
                    Image(self.audioPlayer.audioPlaying ? "pause" : "play")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color("color_text"))
                }
                .frame(width: 45, height: 45)
                
                Button {
                    self.audioPlayer.control(tag: .Next)
                } label: {
                    Image("next")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color("color_text"))
                }
                .frame(width: 35, height: 35)
            }
            .padding(.bottom, 60)
        }
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
