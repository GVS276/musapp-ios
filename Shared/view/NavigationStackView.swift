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
    
    var body: some View
    {
        ZStack
        {
            ForEach(self.model.stacks) { stack in
                stack.wrappedView
                    .transition(.move(edge: .trailing))
                    .offset(x: self.model.previousId == stack.id ?
                            -(UIScreen.main.bounds.width / 2) + abs(self.model.offset / 2) : self.model.offset)
                    .simultaneousGesture(self.model.stacks.count <= 1 ? nil :
                        DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onChanged { value in
                                let x = value.startLocation.x
                                if x >= 0 && x <= 30
                                {
                                    self.model.offset = value.translation.width
                                } else {
                                    self.model.offset = .zero
                                }
                            }
                            .onEnded { value in
                                if abs(self.model.offset) > 30 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.model.offset = UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                                    {
                                        self.model.offset = .zero
                                        self.model.pop()
                                    }
                                } else {
                                    withAnimation {
                                        self.model.offset = .zero
                                    }
                                }
                            }
                    )
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
        HStack(spacing: 0)
        {
            Button {
                NavigationStackViewModel.shared.back()
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
}
