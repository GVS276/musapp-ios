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
    
    @State private var tabIndex = 1
    @State private var playerExpand = false
    
    init()
    {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom))
            {
                switch self.rootStack.root
                {
                case .Main:
                    TabView(selection: $tabIndex) {
                        RootNavigationView {
                            ChartView().environmentObject(audioPlayer)
                        }
                        .tag(0)
                        .ignoresSafeArea(edges: .top)
                        
                        RootNavigationView {
                            LibraryView().environmentObject(audioPlayer)
                        }
                        .tag(1)
                        .ignoresSafeArea(edges: .top)
                        
                        RootNavigationView {
                            SearchView().environmentObject(audioPlayer)
                        }
                        .tag(2)
                        .ignoresSafeArea(edges: .top)
                    }
                    .padding(.bottom, 120)
                    
                    HStack(spacing: 0)
                    {
                        tabButton(iconSet: "action_data", titleSet: "Chart", tag: 0)
                        tabButton(iconSet: "action_my", titleSet: "Library", tag: 1)
                        tabButton(iconSet: "action_search", titleSet: "Search", tag: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color("color_toolbar"))
                    .overlay(Divider(), alignment: .top)
                    
                    PlayerSheetView(expand: $playerExpand)
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
    
    private func tabButton(iconSet: String, titleSet: String, tag: Int) -> some View
    {
        Button {
            if tabIndex == tag {
                rootStack.popToRoot()
            } else {
                tabIndex = tag
            }
        } label: {
            VStack(spacing: 5) {
                Image(iconSet)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tabIndex == tag ? Color("AccentColor") : .secondary)
                    .frame(width: 20, height: 20)
                    
                Text(titleSet)
                    .foregroundColor(tabIndex == tag ? Color("AccentColor") : .secondary)
                    .font(.system(size: 12, weight: .bold))
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
        }
    }
}
