//
//  UIUtils.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import Foundation

enum RequestLoadingStatus {
    // ничего
    case None
    // ошибка выполнения запроса
    case Error
    // полученный запрос с пустыми данными
    case Empty
    // получение данных
    case Receiving
    // получены данные (но можно получить еще)
    case Received
    // получены последние данные (повторять не требуется)
    case ReceivedLast
}

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
}


