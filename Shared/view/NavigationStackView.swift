//
//  NavigationStackView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.08.2022.
//

import SwiftUI

enum Stack {
    case None
    case Main
    case Login
}

class RootStack: ObservableObject
{
    static let shared = RootStack()
    @Published var root: Stack = .None
}

struct NavigationStackView<T: View>: View
{
    @ViewBuilder let content: T
    
    var body: some View
    {
        NavigationView {
            content
        }
    }
}

struct PushView<D: View, L: View>: View
{
    @ViewBuilder let destination: D
    @ViewBuilder let label: L
    
    var body: some View
    {
        NavigationLink {
            destination
        } label: {
            label
        }
    }
}

struct NavigationToolbar<Leading: View, Trailing: View, Content: View>: View
{
    @Environment(\.presentationMode) private var presentationMode
    
    var navTitle: String
    var navBackVisible: Bool
    var navLeading: Leading
    var navTrailing: Trailing
    var content: Content
    
    var bodyToolbar: some View
    {
        HStack(spacing: 0)
        {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image("action_back")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.horizontal, 15)
            .removed(!self.navBackVisible)

            navLeading
                .frame(maxWidth: 100)
                .padding(.leading, self.navBackVisible ? 0 : 15)
            
            Spacer()
            
            navTrailing
                .frame(maxWidth: 100)
                .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 45)
        .background(Color("color_toolbar").ignoresSafeArea(edges: .top))
        .overlay(Text(navTitle)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15), alignment: .center)
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            bodyToolbar
            content
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct NavigationToolbarModifier<Leading: View, Trailing: View>: ViewModifier
{
    var navTitle: String
    var navBackVisible: Bool
    var navLeading: Leading
    var navTrailing: Trailing
    
    func body(content: Content) -> some View {
        NavigationToolbar(navTitle: navTitle,
                          navBackVisible: navBackVisible,
                          navLeading: navLeading,
                          navTrailing: navTrailing,
                          content: content)
    }
}

extension View {
    func viewTitle<Leading: View, Trailing: View>(title: String = "",
                                                  back: Bool = false,
                                                  leading: Leading,
                                                  trailing: Trailing) -> some View
    {
        modifier(NavigationToolbarModifier(navTitle: title,
                                           navBackVisible: back,
                                           navLeading: leading,
                                           navTrailing: trailing))
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        interactivePopGestureRecognizer?.delegate = nil
    }
}
