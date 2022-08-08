//
//  UINavigation.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

public class UINavigation
{
    private static func getNavController() -> UINavigationController?
    {
        if let rootViewController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController
        {
            for children in rootViewController.children {
                if let tabBarController = children as? UITabBarController {
                    let index = tabBarController.selectedIndex
                    let tabBar = children.children[index]
                    for child in tabBar.children {
                        if(child is UINavigationController) {
                            if let navigationController = child as? UINavigationController {
                                return navigationController
                            }
                        }
                    }
                } else {
                    if let navigationController = children as? UINavigationController {
                        return navigationController
                    } else {
                        for child in children.children {
                            if let navigationController = child as? UINavigationController {
                                return navigationController
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public static func pushToView<Content: View>(view: Content)
    {
        if let navigationController = self.getNavController()
        {
            // view content
            let viewController = UIHostingController(rootView: view)
            viewController.navigationItem.largeTitleDisplayMode = .never
            
            // back title
            let backTitle = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController.navigationBar.topItem?.backBarButtonItem = backTitle
            
            // push to view
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
