//
//  NavigationStackViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.08.2022.
//

import SwiftUI

struct ViewStack: Identifiable {
    let id: String
    let wrappedView: AnyView
}

enum NavigationType: Int {
    case push = 0,
         back
}

class NavigationStackViewModel: ObservableObject
{
    static let shared = NavigationStackViewModel()
    
    @Published var stacks: [ViewStack] = []
    @Published var currentView: ViewStack? = nil
    @Published var previousView: ViewStack? = nil
    @Published var navigationType: NavigationType = .push
    
    func root(viewStack: ViewStack)
    {
        self.stacks.removeAll()
        self.stacks.append(viewStack)
        self.currentView = self.stacks.last
        self.previousView = nil
    }
    
    func push(viewStack: ViewStack, anim: Bool = false)
    {
        self.previousView = self.stacks.last
        self.stacks.append(viewStack)
        self.navigationType = .push
        
        if !anim {
            self.currentView = self.stacks.last
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.currentView = self.stacks.last
            }
        }
    }
    
    func back(anim: Bool = false)
    {
        self.navigationType = .back
        self.stacks.removeLast()
        if let last = self.stacks.last, let index = self.stacks.firstIndex(where: {$0.id == last.id})
        {
            if !anim
            {
                self.currentView = last
                self.previousView = index - 1 < 0 ? nil : self.stacks[index - 1]
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.currentView = last
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.previousView = index - 1 < 0 ? nil : self.stacks[index - 1]
                }
            }
        }
    }
}

extension View {
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
}
