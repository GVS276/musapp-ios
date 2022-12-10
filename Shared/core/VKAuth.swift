//
//  VKAuth.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

struct AuthInfo: Decodable
{
    let access_token: String
    let expires_in: Int
    let user_id: Int64
    let secret: String
    let https_required: String
}

struct AuthInfoUpdated: Decodable
{
    let token: String
    let secret: String
}

class VKAuth: VKRequestSession
{
    static let shared = VKAuth()
    
    private let CLIENT_ID = 2274003
    private let CLIENT_SECRET = "hHbZxrka2uZ6jB1inYsH"
    
    func request(login: String,
                 password: String,
                 completionHandler: @escaping ((_ info: AuthInfo?, _ result: RequestResult) -> Void))
    {
        let parameters: [String: Any] = [
            "grant_type": "password",
            "scope": "nohttps,audio",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "validate_token": "true",
            "username": login,
            "password": password
        ]
        
        requestSession(urlString: "https://oauth.vk.com/token", parameters: parameters) { data in
            
            guard let data = data else {
                completionHandler(nil, .ErrorInternet)
                return
            }
            
            guard let obj = try? JSONDecoder().decode(AuthInfo.self, from: data) else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            completionHandler(obj, .Success)
        }
    }
}
