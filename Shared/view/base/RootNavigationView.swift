//
//  RootNavigationView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct RootNavigationView<Root: View>: UIViewControllerRepresentable
{
    let root: Root
    let model: RootStack
    
    func makeUIViewController(context: Context) -> some UINavigationController
    {
        let viewController = UIHostingController(rootView: root)
        viewController.view.backgroundColor = .clear
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.view.backgroundColor = .clear
        nav.navigationBar.isHidden = true
        
        self.model.navigationController = nav
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
