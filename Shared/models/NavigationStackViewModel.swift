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

class NavigationStackViewModel: ObservableObject
{
    static let shared = NavigationStackViewModel()
    
    @Published var stacks: [ViewStack] = []
    @Published var previousId = ""
    @Published var offset: CGFloat = .zero
    
    func root(viewStack: ViewStack)
    {
        self.stacks.removeAll()
        self.stacks.append(viewStack)
        self.previousId = ""
        self.offset = .zero
    }
    
    func push(viewStack: ViewStack, anim: Bool = false)
    {
        self.offset = .zero
        
        if !anim
        {
            self.previousId = self.stacks.last?.id ?? ""
            self.stacks.append(viewStack)
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.previousId = self.stacks.last?.id ?? ""
                self.stacks.append(viewStack)
            }
        }
    }
    
    func pop()
    {
        self.stacks.removeLast()

        if let last = self.stacks.last, let index = self.stacks.firstIndex(where: {$0.id == last.id})
        {
            self.previousId = index - 1 < 0 ? "" : self.stacks[index - 1].id
        }
    }
    
    func back()
    {
        self.offset = 1
        
        withAnimation(.easeInOut(duration: 0.3)) {
            self.offset = UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.offset = .zero
            self.pop()
        }
    }
}

extension View {
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
}
