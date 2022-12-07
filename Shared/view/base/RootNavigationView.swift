//
//  RootNavigationView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct RootNavigationView<Root: View>: UIViewControllerRepresentable
{
    @ViewBuilder let root: Root
    
    func makeUIViewController(context: Context) -> some UINavigationController
    {
        let viewController = UIHostingController(rootView: root)
        viewController.view.backgroundColor = .clear
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.view.backgroundColor = .clear
        nav.navigationBar.isHidden = true
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let viewController = UIHostingController(rootView: root)
        viewController.view.backgroundColor = .clear
        uiViewController.setViewControllers([viewController], animated: false)
    }
}
