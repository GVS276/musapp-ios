//
//  PlayerSheetView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.12.2022.
//

import SwiftUI

struct PlayerSheetView: View
{
    @EnvironmentObject var audioPlayer: AudioPlayerModelView
    @Binding var expand: Bool
    
    @State private var currentTime: Float = .zero
    @State private var repeatAudio = false
    @State private var randomAudio = false
    @State private var touchedSlider = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            /*
             * Header for expanded player
             */
            
            HStack(spacing: 20)
            {
                Button {
                    dismissPlayer()
                } label: {
                    Image("action_down")
                        .resizable()
                        .frame(width: 32, height: 32)
                }

                VStack
                {
                    Text("Album")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    Text(audioPlayer.playedModel?.albumTitle ?? "Unknown")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    
                } label: {
                    Image("menu")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            }
            .frame(height: expand ? nil : 0)
            .opacity(expand ? 1 : 0)
            .padding(.top, expand ? 15 : 0)
            .padding(.horizontal, expand ? 15 : 0)
            
            /*
             * Peek player
             */
            
            HStack(spacing: 15)
            {
                if let art = audioPlayer.art
                {
                    Image(uiImage: art)
                        .resizable()
                        .frame(width: expand ? 200 : 35, height: expand ? 200 : 35)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, expand ? 20 : 0)
                        .padding(.horizontal, expand ? 30 : 0)
                } else {
                    Image("audio")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: expand ? 200 : 35, height: expand ? 200 : 35)
                        .background(Color("color_thumb_dark"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, expand ? 20 : 0)
                        .padding(.horizontal, expand ? 30 : 0)
                }
                
                if !expand {
                    VStack(spacing: 2)
                    {
                        Text(audioPlayer.playedModel?.artist ?? "Nothing is playing right now")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                        
                        Text(audioPlayer.playedModel?.title ?? "Select a track")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                    
                    Button {
                        audioPlayer.control(tag: .PlayOrPause)
                    } label: {
                        Image(audioPlayer.audioPlaying ? "pause" : "play")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color("color_text"))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .frame(height: expand ? nil : 60)
            .padding(.horizontal, 15)

            /*
             * Content
             */
            
            VStack(spacing: 0)
            {
                Text(audioPlayer.playedModel?.artist ?? "Nothing is playing right now")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                
                Text(audioPlayer.playedModel?.title ?? "Select a track")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .padding(.top, 5)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                AudioSliderView(value: currentTime,
                                maxValue: Float(audioPlayer.playedModel?.duration ?? 0),
                                touchedHandler: { touched, currentValue in
                    if !touched {
                        audioPlayer.seek(value: currentValue)
                        audioPlayer.play()
                    } else {
                        if audioPlayer.audioPlaying {
                            audioPlayer.pause()
                        }
                        currentTime = currentValue
                    }
                    touchedSlider = touched
                })
                    .padding(.bottom, 15)
                    .padding(.horizontal, 30)
                    .disabled(audioPlayer.playedModel == nil)
                
                let time = audioPlayer.playedModel == nil ?
                "--  /  --" :
                "\(currentTime.toTime())  /  \(audioPlayer.playedModel?.duration.toTime() ?? "--")"
                
                Text(time)
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .padding(.bottom, 25)
                    .padding(.horizontal, 30)

                HStack(spacing: 0)
                {
                    Button {
                        randomAudio.toggle()
                        audioPlayer.randomAudio(value: randomAudio)
                    } label: {
                        Image(randomAudio ? "random_on" : "random")
                    }
                    
                    Spacer()
                    
                    Button {
                        audioPlayer.control(tag: .Previous)
                    } label: {
                        Image("previous")
                    }
                    
                    Button {
                        audioPlayer.control(tag: .PlayOrPause)
                    } label: {
                        Image(audioPlayer.audioPlaying ? "pause_circle" : "play_circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal, 20)
                    
                    Button {
                        audioPlayer.control(tag: .Next)
                    } label: {
                        Image("next")
                    }
                    
                    Spacer()
                    
                    Button {
                        repeatAudio.toggle()
                        audioPlayer.repeatAudio(value: repeatAudio)
                    } label: {
                        Image(repeatAudio ? "repeat_on" : "repeat")
                    }
                }
                .padding(.bottom, 60)
                .padding(.horizontal, 30)
            }
            .frame(height: expand ? nil : 0)
            .opacity(expand ? 1 : 0)
            
        }
        .frame(maxHeight: expand ? .infinity : 60)
        .background(
            !expand ? Color("color_toolbar") :
                Color(uiColor: audioPlayer.artColor ?? UIColor(named: "color_player_default") ?? .clear)
        )
        .offset(y: expand ? 0 : -60)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    
                    if !expand &&
                        value.translation.width > -100 &&
                        value.translation.width < 100 &&
                        value.translation.height < 0
                    {
                        expandPlayer()
                    }
                    
                    else if expand &&
                                value.translation.width > -100 &&
                                value.translation.width < 100 &&
                                value.translation.height > 0
                    {
                        dismissPlayer()
                    }
            }
        )
        .onTapGesture {
            if !expand {
                expandPlayer()
            }
        }
    }
    
    private func initTimer()
    {
        currentTime = audioPlayer.currentTime()
        audioPlayer.initCurrentTime { current in
            currentTime = current
        }
    }
    
    private func openedPlayer()
    {
        repeatAudio = self.audioPlayer.isRepeatAudio()
        randomAudio = self.audioPlayer.isRandomAudio()
        initTimer()
    }
    
    private func closedPlayer()
    {
        audioPlayer.removeCurrentTime()
    }
    
    private func dismissPlayer()
    {
        closedPlayer()
        
        withAnimation(.spring()) {
            expand = false
        }
    }
    
    private func expandPlayer()
    {
        openedPlayer()
        
        withAnimation(.spring()) {
            expand = true
        }
    }
}
