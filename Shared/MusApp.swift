//
//  MusApp.swift
//  Shared
//
//  Created by Виктор Губин on 04.08.2022.
//

import SwiftUI

@main
struct MusApp: App
{
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject private var rootStack = RootStack.shared
    @ObservedObject private var audioPlayer = AudioPlayerModelView()
    
    init()
    {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0)
            {
                NavigationStackView {
                    switch self.rootStack.root {
                    case .Main: MainView().environmentObject(self.audioPlayer)
                    case .Login: LoginView().environmentObject(self.rootStack)
                    default: EmptyView()
                    }
                }
                
                self.miniPlayer()
                    .removed(!self.audioPlayer.audioPlayerReady)
            }
            .sheet(isPresented: self.$audioPlayer.playerSheet, content: {
                PlayerView().environmentObject(self.audioPlayer)
            })
            .ignoresSafeArea(.keyboard)
            //.createToastView()
            .onAppear {
                // Root
                self.rootStack.root = UIUtils.getInfo() != nil ? .Main : .Login
                
                // MP Center
                self.audioPlayer.setupCommandCenter()
            }
        }
    }
    
    private func miniPlayer() -> some View
    {
        HStack(spacing: 0)
        {
            AudioThumbView(color: .blue)
                .padding(.horizontal, 15)
            
            VStack
            {
                Text(self.audioPlayer.playedModel?.model.artist ?? "Artist")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
                
                Text(self.audioPlayer.playedModel?.model.title ?? "Title")
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
            }
            .padding(.trailing, 15)
            
            Button {
                self.audioPlayer.control(tag: .PlayOrPause)
            } label: {
                Image(self.audioPlayer.audioPlaying ? "pause" : "play")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color("color_text"))
            }
            .frame(width: 30, height: 30)
            .padding(15)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color("color_toolbar").edgesIgnoringSafeArea(.bottom))
        .onTapGesture {
            self.audioPlayer.playerSheet = true
        }
    }
}
