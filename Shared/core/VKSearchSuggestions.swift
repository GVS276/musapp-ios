//
//  VKSearchSuggestions.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

class VKSearchSuggestions: VKRequestSession
{
    static let shared = VKSearchSuggestions()
    
    func request(completionHandler: @escaping ((_ list: [Suggestion]?,
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
        
        let method = methodLine(method: "catalog.getAudioSearch",
                                token: token,
                                param: [],
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
            
            guard let suggestions = param["suggestions"] as? NSArray else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            var list = [Suggestion]()
            
            suggestions.forEach { item in
                
                if let item = item as? [String: Any] {
                    
                    let suggestion = Suggestion(
                        id: item["id"] as? String,
                        title: item["title"] as? String,
                        subtitle: item["subtitle"] as? String,
                        context: item["context"] as? String
                    )
                    
                    list.append(suggestion)
                }
            }
            
            completionHandler(list, .Success)
        }
    }
}
