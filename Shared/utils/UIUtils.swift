//
//  UIUtils.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import Foundation

class UIUtils
{
    static func updateInfo(token: String, secret: String, userId: Int64 = -1)
    {
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.set(secret, forKey: "secret")
        
        if userId != -1
        {
            UserDefaults.standard.set(userId, forKey: "userId")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    static func getInfo() -> [String: Any]?
    {
        if let token = UserDefaults.standard.object(forKey: "token") as? String,
           let secret = UserDefaults.standard.object(forKey: "secret") as? String,
           let userId = UserDefaults.standard.object(forKey: "userId") as? Int64
        {
            let info: [String: Any] = [
                "token": token,
                "secret": secret,
                "userId": userId
            ]
            
            return info
        }
        return nil
    }
    
    static func isLastAudio(list: [AudioStruct], audio: AudioStruct) -> Bool
    {
        guard !list.isEmpty else {
            return false
        }
        
        guard let itemIndex = list.lastIndex(where: { $0.id == audio.id }) else {
            return false
        }
        
        let distance = list.distance(from: itemIndex, to: list.endIndex)
        return distance == 1
    }
    
    static func isPagination(list: [AudioStruct], audio: AudioStruct, offset: Int) -> Bool
    {
        guard !list.isEmpty else {
            return false
        }
        
        guard let itemIndex = list.lastIndex(where: { $0.id == audio.id }) else {
            return false
        }
        
        let distance = list.distance(from: itemIndex, to: list.endIndex)
        let offset = offset < list.count ? offset : list.count - 1
        return offset == (distance - 1)
    }
}


