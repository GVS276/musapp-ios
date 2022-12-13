//
//  VKPlaylist.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import Foundation

class VKPlaylist: VKRequestSession
{
    static let shared = VKPlaylist()
    
    func request(playlistId: String,
                 ownerId: String,
                 accessKey: String,
                 count: Int,
                 offset: Int,
                 completionHandler: @escaping ((_ playlist: AlbumModel?,
                                                _ list: [AudioModel]?,
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
        
        let method = methodLine(method: "execute.getPlaylist",
                                token: token,
                                param: ["id=\(playlistId)",
                                        "owner_id=\(ownerId)",
                                        "access_key=\(accessKey)",
                                        "audio_count=\(count)",
                                        "audio_offset=\(offset)",
                                        "need_owner=0",
                                        "need_playlist=1"],
                                needBlocks: true,
                                apiVer: "5.138",
                                lang: "ru")
        
        let hash = "\(method)\(secret)".md5
        
        let urlString = "https://api.vk.com\(method)&sig=\(hash)"
        
        requestSession(urlString: urlString) { data in
            
            guard let data = data else {
                completionHandler(nil, nil, .ErrorInternet)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
            {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            guard let param = json["response"] as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            guard let playlist = param["playlist"] as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            guard let audios = param["audios"] as? [[String: Any]] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            let model = self.convertToAlbumModel(item: playlist)
            
            let list = self.parseAudioList(audios: audios)
            
            completionHandler(model, list, .Success)
        }
    }
}
