//
//  VKArtist.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

class VKArtist: VKRequestSession
{
    static let shared = VKArtist()
    
    func request(artistDomain: String,
                 completionHandler: @escaping ((_ section: Section?,
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
        
        let method = methodLine(method: "catalog.getAudioArtist",
                                token: token,
                                param: ["artist_id=\(artistDomain)"],
                                needBlocks: true,
                                apiVer: "5.138",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(nil, .ErrorInternet)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let param = json["response"] as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let cat = param["catalog"] as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let def = cat["default_section"] as? String else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let sections = cat["sections"] as? [[String: Any]] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let item = sections.first(where: {($0["id"] as? String) == def}) else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            let section = self.parseSection(param: param, item: item, count: 5)
            
            completionHandler(section, .Success)
        }
    }
}
