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
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onlyLeading()
            }
            .padding(.leading, 15)
            
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
            .padding(.vertical, 15)
            
            Button {
                self.audioPlayer.control(tag: .Next)
            } label: {
                Image("next")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color("color_text"))
            }
            .frame(width: 30, height: 30)
            .padding(.vertical, 15)
            .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color("color_toolbar").edgesIgnoringSafeArea(.bottom))
        .onTapGesture {
            self.audioPlayer.playerSheet = true
        }
    }
}
