//
//  NavigationStackView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.08.2022.
//

import Foundation
import SwiftUI

struct NavigationStackView: View
{
    @EnvironmentObject var model: NavigationStackViewModel
    
    var body: some View
    {
        Group
        {
            if let view = self.model.currentView?.wrappedView
            {
                let tran = self.model.navigationType == .push ?
                AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)) :
                AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                view.transition(tran)
            } else {
                // Splash
                EmptyView()
            }
        }
    }
}

struct NavigationToolbar<ContentLeading, ContentTrailing>: View where ContentLeading: View,
                                                                      ContentTrailing: View
{
    var navTitle = ""
    var navBackVisible = false
    var navLeading: ContentLeading
    var navTrailing: ContentTrailing
    
    var body: some View
    {
        HStack
        {
            Button {
                withAnimation {
                    NavigationStackViewModel.shared.back()
                }
            } label: {
                Image("action_back")
            }
            .padding(.horizontal, 15)
            .removed(!self.navBackVisible)

            navLeading
                .frame(maxWidth: .infinity)
                .padding(.leading, self.navBackVisible ? 0 : 15)
            
            Text(navTitle)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
            
            navTrailing
                .frame(maxWidth: .infinity)
                .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 45)
        .background(Color("color_toolbar").ignoresSafeArea(edges: .top))
    }
}
