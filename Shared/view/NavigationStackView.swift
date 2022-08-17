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
    @GestureState private var gestureState: CGSize = .zero
    
    var body: some View
    {
        let swipeBack = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating(self.$gestureState) { value, state, _ in
                if value.startLocation.x <= 30
                {
                    let diff = CGSize(
                        width: value.location.x - value.startLocation.x,
                        height: value.location.y - value.startLocation.y
                    )
                    
                    state = diff == .zero ? .zero : value.translation
                } else {
                    state = .zero
                }
            }
        
        ZStack
        {
            // ZStack необходим для наложения вью на вью
            // Для сохранения состояния предыдущего вью, необходимо использовать ForEach
            // из листа stacks происходит наложения нового вью друг на друга
            // таким способом добиваемся анимации при открытии / закрытии и также при свайпе вправо (для выхода)
            // если вью не текущее, то все вью в стеке (до текущего) будут блокированы
            ForEach(self.model.stacks) { stack in
                let width = UIScreen.main.bounds.width / 2
                let offset = abs(self.model.offset / 2)
                
                let transition = self.model.previousId == stack.id ? -width + offset :
                                 self.model.currentId == stack.id ? self.model.offset : 0
                
                stack.wrappedView
                    .transition(.move(edge: .trailing))
                    .offset(x: transition)
                    .disabled(self.model.currentId != stack.id)
            }
        }
        .simultaneousGesture(self.model.stacks.count <= 1 ? nil : swipeBack)
        .highPriorityGesture(self.model.stacks.count <= 1 ? nil : swipeBack)
        .onChange(of: self.gestureState) { value in
            if value == .zero
            {
                if abs(self.model.offset) > 30 {
                    self.model.back()
                } else {
                    withAnimation {
                        self.model.offset = .zero
                    }
                }
            } else {
                let x = value.width
                
                if x < 0
                {
                    return
                }
                
                self.model.offset = x
            }
        }
    }
}

struct NavigationToolbar<Leading: View, Trailing: View, Content: View>: View
{
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
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            bodyToolbar
            content
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
