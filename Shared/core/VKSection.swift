//
//  VKSection.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

import Foundation

class VKSection: VKRequestSession
{
    static let shared = VKSection()
    
    func request(sectionId: String,
                 completionHandler: @escaping ((_ section: Section?,
                                                _ banners: [CatalogBanner]?,
                                                _ result: RequestResult) -> Void))
    {
        guard let info = UIUtils.getInfo() else {
            completionHandler(nil, nil, .ErrorRequest)
            return
        }
        
        guard let token = info["token"] as? String else {
            completionHandler(nil, nil, .ErrorRequest)
            return
        }
        
        guard let secret = info["secret"] as? String else {
            completionHandler(nil, nil, .ErrorRequest)
            return
        }
        
        let method = methodLine(method: "catalog.getSection",
                                token: token,
                                param: ["section_id=\(sectionId)"],
                                needBlocks: false,
                                apiVer: "5.138",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(nil, nil, .ErrorInternet)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            guard let param = json["response"] as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            guard let item = param["section"] as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            var banners: [CatalogBanner] = []
            
            if let list = param["catalog_banners"] as? NSArray {
                banners = self.parseBanners(listBanners: list)
            }
            
            let section = self.parseSection(item: item)
            
            completionHandler(section, banners, .Success)
        }
    }
}
