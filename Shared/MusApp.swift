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
        navBar.tintColor = UIColor(.white)
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
                NavigationView
                {
                    MainView()
                        .environmentObject(self.audioPlayer)
                        .environmentObject(self.mainModel)
                        .navigationBarHidden(false)
                }
            default:
                EmptyView()
            }
        }
    }
}
