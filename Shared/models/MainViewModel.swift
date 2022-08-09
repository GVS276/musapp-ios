//
//  MainViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

enum MainScene {
    case none
    case main
    case login
}

class MainViewModel: ObservableObject
{
    static let shared = MainViewModel()
    var onViewScene: ((_ scene: MainScene) -> Void)?
    
    func showScene(scene: MainScene)
    {
        if let callback = self.onViewScene
        {
            callback(scene)
        }
    }
}
