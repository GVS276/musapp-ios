//
//  AppDelegate.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate
{
    private var isRequest = true
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.refreshToken()
        return true
    }
    
    private func refreshToken()
    {
        if !self.isRequest {
            return
        }
        
        if let info = UIUtils.getInfo()
        {
            let token = info["token"] as! String
            let secret = info["secret"] as! String
            
            self.isRequest = false
            
            VKViewModel.shared.refreshToken(token: token, secret: secret) { refresh, result in
                switch result {
                case .ErrorInternet:
                    print("Problems with the Internet")
                case .ErrorRequest:
                    print("An error occurred when accessing the server")
                case .Success:
                    print("Info updated")
                    UIUtils.updateInfo(token: refresh!.response.token, secret: refresh!.response.secret)
                }
            }
        }
    }
}
