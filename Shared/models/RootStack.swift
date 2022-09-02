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

struct StackView<Content: View>: View
{
    var title: String = ""
    var back: Bool = true
    
    @ViewBuilder let content: Content
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 15)
            {
                Button {
                    RootStack.shared.popToView()
                } label: {
                    Image("action_back")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                .removed(!back)

                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .removed(title.isEmpty)
                
                Spacer()
            }
            .frame(height: 45)
            .padding(.horizontal, 15)
            .background(Color("color_toolbar").ignoresSafeArea(edges: .top))
            
            content
        }
        .background(Color("color_background"))
    }
}
