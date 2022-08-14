//
//  NavigationStackViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.08.2022.
//

import SwiftUI

struct ViewStack: Identifiable {
    let id: Int
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
    @Published var navigationType: NavigationType = .push
    
    func addView(stack: ViewStack)
    {
        self.stacks.append(stack)
    }
    
    func setCurrentView(idStack: Int, type: NavigationType = .push)
    {
        if let index = self.stacks.firstIndex(where: {$0.id == idStack}) {
            self.navigationType = type
            self.currentView = self.stacks[index]
        }
    }
    
    func back()
    {
        if let currentId = self.currentView?.id
        {
            let backId = currentId - 1 < 0 ? 0 : currentId - 1
            self.setCurrentView(idStack: backId, type: .back)
        }
    }
}
