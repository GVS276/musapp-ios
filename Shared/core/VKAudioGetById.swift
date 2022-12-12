//
//  VKAudioGetById.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

class VKAudioGetById: VKRequestSession
{
    static let shared = VKAudioGetById()
    
    func request(audios: [String],
                 completionHandler: @escaping ((_ list: [AudioModel]?,
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
        
        let joined = audios.joined(separator: ", ")
        
        guard let encoded = joined.encoded else {
            completionHandler(nil, .ErrorRequest)
            return
        }
        
        let method = methodLine(method: "audio.getById",
                                token: token,
                                param: ["audios=\(encoded)"],
                                needBlocks: false,
                                apiVer: "5.95",
                                lang: "ru")
        
        let methodForHash = methodLine(method: "audio.getById",
                                       token: token,
                                       param: ["audios=\(joined)"],
                                       needBlocks: false,
                                       apiVer: "5.95",
                                       lang: "ru")
        
        let hash = "\(methodForHash)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(nil, .ErrorInternet)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
            {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let audios = json["response"] as? [[String: Any]] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            let list = self.parseAudioList(audios: audios)
            
            completionHandler(list, .Success)
        }
    }
}
