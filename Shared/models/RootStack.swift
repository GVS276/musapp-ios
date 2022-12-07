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
    
    @Published var root: Stack = .None
    
    func pushToView<Content: View>(view: Content)
    {
        if let navigationController = getNavigationController()
        {
            let viewController = UIHostingController(rootView: view)
            navigationController.navigationBar.isHidden = true
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func popToView()
    {
        getNavigationController()?.popViewController(animated: true)
    }
    func popToRoot()
    {
        getNavigationController()?.popToRootViewController(animated: true)
    }
    
    func getRootViewController() -> UIViewController?
    {
        if #available(iOS 14, *) {
            return UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .rootViewController
        } else {
            return UIApplication.shared
                .windows
                .first { $0.isKeyWindow }?
                .rootViewController
        }
    }
    
    func getNavigationController() -> UINavigationController?
    {
        guard let rootViewController = getRootViewController() else { return nil }
        
        for children in rootViewController.children {
            if let tabBarController = children as? UITabBarController {
                let selectedView = tabBarController.selectedViewController
                
                if let navigationController = selectedView?.children[0] as? UINavigationController {
                    return navigationController
                }
            }
        }
        
        return nil
    }
}
