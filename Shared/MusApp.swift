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
                switch self.rootStack.root
                {
                case .Main:
                    RootNavigationView(
                        root: MainView().environmentObject(self.audioPlayer),
                        model: self.rootStack
                    ).ignoresSafeArea()
                case .Login:
                    LoginView().environmentObject(self.rootStack)
                default:
                    EmptyView()
                }
                
                self.miniPlayer()
                    .removed(!self.audioPlayer.audioPlayerReady)
            }
            .ignoresSafeArea(.keyboard)
            .overlay(MenuDialogView().environmentObject(self.audioPlayer))
            .sheet(isPresented: self.$audioPlayer.playerSheet, content: {
                PlayerView().environmentObject(self.audioPlayer)
            })
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
        HStack(spacing: 20)
        {
            VStack(spacing: 2)
            {
                Text(self.audioPlayer.playedModel?.artist ?? "Artist")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 5)
                {
                    Image("action_explicit")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .frame(width: 14, height: 14)
                        .removed(!(self.audioPlayer.playedModel?.isExplicit ?? false))
                    
                    Text(self.audioPlayer.playedModel?.title ?? "Title")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Button {
                self.audioPlayer.control(tag: .PlayOrPause)
            } label: {
                Image(self.audioPlayer.audioPlaying ? "pause" : "play")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 15)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background(Color("color_toolbar").edgesIgnoringSafeArea(.bottom))
        .onTapGesture {
            self.audioPlayer.playerSheet.toggle()
        }
    }
}
