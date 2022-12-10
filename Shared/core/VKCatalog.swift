//
//  VKCatalog.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

import Foundation

class VKCatalog: VKRequestSession
{
    static let shared = VKCatalog()
    
    func request(completionHandler: @escaping ((_ catalog: Catalog?,
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
        
        let method = methodLine(method: "catalog.getAudio",
                                token: token,
                                param: [],
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
            
            var sections = [CatalogSection]()
            
            if let list = cat["sections"] as? NSArray
            {
                list.forEach { item in
                    
                    if let item = item as? [String: String] {
                        
                        let section = CatalogSection(
                            id: item["id"],
                            title: item["title"],
                            url: item["url"]
                        )
                        
                        sections.append(section)
                    }
                }
            }
            
            let catalog = Catalog(
                defaultSection: cat["default_section"] as? String,
                sections: sections
            )
            
            completionHandler(catalog, .Success)
        }
    }
}
