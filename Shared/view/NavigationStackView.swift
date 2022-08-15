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
    @EnvironmentObject private var model: NavigationStackViewModel
    @State private var offset: CGFloat = .zero
    
    var body: some View
    {
        ZStack
        {
            if let previous = self.model.previousView?.wrappedView
            {
                previous
                    .offset(x: -UIScreen.main.bounds.width + self.offset)
                    .removed(self.offset == .zero)
            }
            
            if let current = self.model.currentView?.wrappedView
            {
                let tran = self.model.navigationType == .push ?
                AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)) :
                AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                
                current
                    .transition(tran)
                    .offset(x: self.offset)
                    .simultaneousGesture(self.model.stacks.count <= 1 ? nil :
                        DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onChanged { value in
                                let x = value.startLocation.x
                                if x >= 0 && x <= 30
                                {
                                    self.offset = value.translation.width
                                } else {
                                    self.offset = .zero
                                }
                            }
                            .onEnded { value in
                                if abs(self.offset) > 30 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.offset = UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                                    {
                                        self.offset = .zero
                                        self.model.back()
                                    }
                                } else {
                                    withAnimation {
                                        self.offset = .zero
                                    }
                                }
                            }
                    )
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
                NavigationStackViewModel.shared.back(anim: true)
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
