//
//  VKButtonTracks.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

import Foundation

class VKButtonTracks: VKRequestSession
{
    static let shared = VKButtonTracks()
    
    func request(buttonSectionId: String,
                 count: Int,
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
        
        let method = methodLine(method: "audio.getButtonTracks",
                                token: token,
                                param: ["id=\(buttonSectionId)",
                                        "count=\(count)"],
                                needBlocks: false,
                                apiVer: "5.138",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
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
            
            guard let param = json["response"] as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let audios = param["audios"] as? NSArray else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            let list = self.parseAudioList(audios: audios)
            
            completionHandler(list, .Success)
        }
    }
}
