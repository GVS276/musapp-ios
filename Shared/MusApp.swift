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
            ZStack(alignment: .bottom)
            {
                switch self.rootStack.root
                {
                case .Main:
                    RootNavigationView(root: MainView().environmentObject(audioPlayer), model: rootStack)
                        .ignoresSafeArea()
                        .padding(.bottom, 65)
                    
                    PlayerView()
                        .environmentObject(audioPlayer)
                case .Login:
                    LoginView()
                        .environmentObject(rootStack)
                default:
                    EmptyView()
                }
                
                MenuDialogView()
                    .environmentObject(audioPlayer)
            }
            .background(Color("color_background"))
            .ignoresSafeArea(.keyboard)
            .overlay(ToastView(), alignment: .bottom)
            .onAppear {
                // Root
                rootStack.root = UIUtils.getInfo() != nil ? .Main : .Login
                
                // MP Center
                audioPlayer.setupCommandCenter()
            }
        }
    }
}
