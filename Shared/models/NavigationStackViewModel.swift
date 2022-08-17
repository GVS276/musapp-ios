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
    @Published var currentId = ""
    @Published var previousId = ""
    @Published var offset: CGFloat = .zero
    
    func root<T: View>(view: T, tag: String)
    {
        let viewStack = ViewStack(id: tag, wrappedView: view.toAnyView())
        self.stacks.removeAll()
        self.stacks.append(viewStack)
        self.currentId = viewStack.id
        self.previousId = ""
        self.offset = .zero
    }
    
    func push<T: View>(view: T, tag: String)
    {
        let viewStack = ViewStack(id: tag, wrappedView: view.toAnyView())
        withAnimation(.easeInOut(duration: 0.3)) {
            self.previousId = self.stacks.last?.id ?? ""
            self.currentId = viewStack.id
            self.stacks.append(viewStack)
        }
    }
    
    func pop()
    {
        self.stacks.removeLast()

        if let last = self.stacks.last, let index = self.stacks.firstIndex(where: {$0.id == last.id})
        {
            self.currentId = last.id
            self.previousId = index - 1 < 0 ? "" : self.stacks[index - 1].id
        }
    }
    
    func back()
    {
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
