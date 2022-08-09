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
    @ObservedObject private var audioPlayer = AudioPlayerModelView()
    @ObservedObject private var mainModel = MainViewModel.shared
    @State private var currentScene: MainScene = .none
    
    init()
    {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.shadowColor = UIColor(Color("color_toolbar"))
        coloredAppearance.backgroundColor = UIColor(Color("color_toolbar"))
                
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = UIColor(Color("color_text"))
        navBar.standardAppearance = coloredAppearance
        navBar.scrollEdgeAppearance = coloredAppearance
        navBar.compactAppearance = coloredAppearance
        
        // keyboard theme
        UITextField.appearance().keyboardAppearance = .dark
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    var body: some Scene {
        WindowGroup {
            mainScene
                .overlay(PlayerView()
                            .environmentObject(self.audioPlayer))
                .createToastView()
                .onAppear {
                    // for test
                    if UserDefaults.standard.object(forKey: "login") != nil,
                       UserDefaults.standard.object(forKey: "password") != nil
                    {
                        self.currentScene = .main
                    } else {
                        self.currentScene = .login
                    }
                    // --------
                    
                    self.mainModel.onViewScene = { scene in
                        DispatchQueue.main.async {
                            self.currentScene = scene
                        }
                    }
                    
                    self.audioPlayer.setupCommandCenter()
                }
        }
    }
    
    var mainScene: some View
    {
        Group
        {
            switch currentScene
            {
            case .login:
                NavigationView
                {
                    LoginView()
                        .environmentObject(self.mainModel)
                        .navigationBarHidden(true)
                }
            case .main:
                VStack(spacing: 0)
                {
                    NavigationView
                    {
                        MainView()
                            .environmentObject(self.audioPlayer)
                            .navigationBarHidden(false)
                    }
                    
                    self.miniPlayer()
                        .removed(!self.audioPlayer.audioPlayerReady)
                }
                .ignoresSafeArea(.keyboard)
            default:
                EmptyView()
            }
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
            withAnimation {
                self.audioPlayer.playerMode = .FULL
            }
        }
    }
}
