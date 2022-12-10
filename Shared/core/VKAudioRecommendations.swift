//
//  VKAudioRecommendations.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

class VKAudioRecommendations: VKRequestSession
{
    static let shared = VKAudioRecommendations()
    
    func request(audioId: String,
                 audioOwnerId: String,
                 completionHandler: @escaping ((_ count: Int,
                                                _ list: [AudioModel]?,
                                                _ result: RequestResult) -> Void))
    {
        guard let info = UIUtils.getInfo() else {
            completionHandler(0, nil, .ErrorRequest)
            return
        }
        
        guard let token = info["token"] as? String else {
            completionHandler(0, nil, .ErrorRequest)
            return
        }
        
        guard let secret = info["secret"] as? String else {
            completionHandler(0, nil, .ErrorRequest)
            return
        }
        
        let targetAudio = "\(audioOwnerId)_\(audioId)"
        
        let method = methodLine(method: "audio.getRecommendations",
                                token: token,
                                param: ["target_audio=\(targetAudio)",
                                        "count=100"],
                                needBlocks: false,
                                apiVer: "5.95",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(0, nil, .ErrorInternet)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
            {
                completionHandler(0, nil, .ErrorRequest)
                return
            }
            
            guard let param = json["response"] as? [String: Any] else {
                completionHandler(0, nil, .ErrorRequest)
                return
            }
            
            guard let count = param["count"] as? Int else {
                completionHandler(0, nil, .ErrorRequest)
                return
            }
            
            guard let items = param["items"] as? NSArray else {
                completionHandler(0, nil, .ErrorRequest)
                return
            }
            
            
            if count == -1 {
                
                completionHandler(0, nil, .ErrorRequest)
                
            } else {
                
                let list = self.parseAudioList(audios: items)
                
                completionHandler(count, list, .Success)
            }
        }
    }
}
