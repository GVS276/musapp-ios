//
//  RootStack.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 01.09.2022.
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
    var navigationController: UINavigationController? = nil
    
    @Published var root: Stack = .None
    
    func pushToView<Content: View>(view: Content)
    {
        if let navigationController = self.navigationController
        {
            let viewController = UIHostingController(rootView: view)
            navigationController.navigationBar.isHidden = true
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func popToView()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
