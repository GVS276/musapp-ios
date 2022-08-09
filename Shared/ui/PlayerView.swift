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
    @State private var sliderProgress: Float = .zero
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Button {
                self.audioPlayer.playerMode = .MINI
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
                .padding(.horizontal, 30)
                .padding(.bottom, 8)
                .onlyLeading()
            
            Text(self.audioPlayer.playedModel?.model.title ?? "Title")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Spacer()
            
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
            .padding(.bottom, 15)
            
            Slider(value: self.$sliderProgress, in: 0...100)
                .padding(.bottom, 30)
                .padding(.horizontal, 30)
            
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
            
            Button {
                
            } label: {
                Image("text")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color("color_text"))
            }
            .frame(width: 35, height: 35)
            .padding(.bottom, 30)
        }
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .transition(.move(edge: .bottom))
        .onTapGesture {}
        .onAppear(perform: {
            self.audioPlayer.addProgress { current, duration in
                self.currentTime = current
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
