//
//  VKAuthRefreshToken.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

struct Response: Decodable
{
    let response: AuthInfoUpdated
}

class VKAuthRefreshToken: VKRequestSession
{
    static let shared = VKAuthRefreshToken()
    
    func request(completionHandler: @escaping ((_ response: Response?,
                                                _ result: RequestResult) -> Void))
    {
        guard let info = UIUtils.getInfo() else {
            completionHandler(nil, .ErrorRequest)
            return
        }
        
        guard let token = info["token"] as? String else {
            completionHandler(nil, .ErrorRequest)
            return
        }
        
        guard let secret = info["secret"] as? String else {
            completionHandler(nil, .ErrorRequest)
            return
        }
        
        let method = methodLine(method: "auth.refreshToken",
                                token: token,
                                param: [],
                                needBlocks: false,
                                apiVer: "5.95",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(nil, .ErrorInternet)
                return
            }
            
            guard let obj = try? JSONDecoder().decode(Response.self, from: data) else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            completionHandler(obj, .Success)
        }
    }
}
