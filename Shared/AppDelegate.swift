//
//  AppDelegate.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate
{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        return true
    }
}
