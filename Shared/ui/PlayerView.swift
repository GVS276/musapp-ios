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
    @State private var currentDuration: Float = .zero
    
    @State private var repeatAudio = false
    @State private var randomAudio = false
    @State private var touchedSlider = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Button {
                withAnimation(.easeInOut) {
                    self.audioPlayer.playerMode = .MINI
                }
            } label: {
                HStack(spacing: 0)
                {
                    Image("action_down")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .padding(15)
                    
                    Text("Currently playing")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                    
                    Image("action_down")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .padding(15)
                }
            }
            
            VStack
            {
                Image("music")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
            }
            .frame(width: 300, height: 300)
            .background(Color("color_thumb"))
            .cornerRadius(20)
            .padding(30)
            
            Text(self.audioPlayer.playedModel?.model.artist ?? "Artist")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 18))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 8)
            
            Text(self.audioPlayer.playedModel?.model.title ?? "Title")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
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
            
            AudioSliderView(value: self.$currentTime, maxValue: self.$currentDuration, touchedHandler: { touched in
                if !touched {
                    self.audioPlayer.seek(value: self.currentTime)
                    self.audioPlayer.play()
                } else {
                    self.audioPlayer.pause()
                }
                self.touchedSlider = touched
            })
                .padding(.bottom, 10)
                .padding(.horizontal, 30)
            
            HStack
            {
                Text(UIUtils.getTimeFromDuration(sec: Int(self.currentTime)))
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                
                Spacer()
                
                Text(UIUtils.getTimeFromDuration(sec: Int(self.audioPlayer.playedModel?.model.duration ?? 0)))
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
                    self.playOrPause()
                } label: {
                    Image((self.audioPlayer.playedModel?.isPlaying ?? false) ? "pause" : "play")
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
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .transition(.move(edge: .bottom))
        .onTapGesture {}
        .simultaneousGesture(self.touchedSlider ? nil :
            DragGesture(minimumDistance: 100, coordinateSpace: .local)
                .onChanged { value in
                    if value.startLocation.y < value.location.y, self.audioPlayer.playerMode == .FULL
                    {
                        withAnimation(.easeInOut) {
                            self.audioPlayer.playerMode = .MINI
                        }
                    }
                }
        )
        .onAppear(perform: {
            self.repeatAudio = self.audioPlayer.isRepeatAudio()
            self.randomAudio = self.audioPlayer.isRandomAudio()
            self.audioPlayer.addProgress { current, duration in
                if duration != .zero
                {
                    self.currentTime = current
                    self.currentDuration = duration
                }
            }
        })
        .removed(self.audioPlayer.playerMode == .MINI)
    }
    
    private func playOrPause()
    {
        if let model = self.audioPlayer.playedModel
        {
            if model.isPlaying {
                self.audioPlayer.pause()
            } else {
                self.audioPlayer.play()
            }
        }
    }
}
