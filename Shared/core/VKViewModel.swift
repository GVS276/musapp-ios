//
//  VKViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import UIKit

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

enum RequestResult {
    case ErrorInternet
    case ErrorRequest
    case Success
}

struct Response: Decodable
{
    let response: AuthInfoUpdated
}

struct CatalogBanner
{
    let id: Int?
    let title: String?
    let text: String?
    let subtext: String?
    let trackCode: String?
    let imageMode: String?
    let image: String?
    let url: String?
}

struct CatalogSection
{
    let id: String?
    let title: String?
    let url: String?
}

struct Catalog
{
    var defaultSection: String = ""
    var sections: [CatalogSection] = []
}

struct SectionLayout
{
    let name: String?
    let title: String?
    let ownerId: Int?
    let infiniteRepeat: Bool = false
}

struct SectionButton
{
    let sectionId: String?
    let title: String?
    let refItemsCount: Int?
    let refLayoutName: String?
    let refDataType: String?
}

struct SectionBlock
{
    let id: String?
    let dataType: String?
    let layout: SectionLayout?
    let buttons: [SectionButton]?
    let catalogBannerIds: [Int]?
    let nextFrom: String?
    let url: String?
    let audiosIds: [String]?
    let playlistsIds: [String]?
}

struct Section
{
    let id: String?
    let title: String?
    let blocks: [SectionBlock]
    let nextFrom: String?
    let url: String?
}

struct Suggestion
{
    let id: String?
    let title: String?
    let subtitle: String?
    let context: String?
}

class VKViewModel
{
    static let shared = VKViewModel()
    
    private let CLIENT_ID = 2274003
    private let CLIENT_SECRET = "hHbZxrka2uZ6jB1inYsH"
    private let USER_AGENT = "VKAndroidApp/5.52-4543 (Android 5.1.1; SDK 22; x86_64; unknown Android SDK built for x86_64; en; 320x240)"
    
    private func getDeviceId() -> String
    {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    private func requestSession(urlString: String,
                                parameters: [String: Any]? = nil,
                                completionHandler: @escaping ((_ data: Data?) -> Void))
    {
        print("requestSession ++")
        
        if let url = URL(string: urlString)
        {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
            
            if let parameters = parameters
            {
                request.httpBody = parameters.percentEncoded()
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    print("error", error ?? URLError(.badServerResponse))
                    completionHandler(nil)
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode = \(response.statusCode)")
                    print("response = \(response)")
                    completionHandler(nil)
                    return
                }
                
                completionHandler(data)
            }

            task.resume()
        }
    }
    
    func doAuth(login: String,
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
        
        self.requestSession(urlString: "https://oauth.vk.com/token", parameters: parameters) { data in
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
    
    func refreshToken(token: String,
                      secret: String,
                      completionHandler: @escaping ((_ response: Response?, _ result: RequestResult) -> Void))
    {
        let method = "/method/auth.refreshToken?access_token=\(token)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func getAudioList(token: String,
                      secret: String,
                      userId: Int64,
                      count: Int = 25,
                      offset: Int = 0,
                      completionHandler: @escaping ((_ count: Int,
                                                     _ list: [AudioModel]?,
                                                     _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.get?access_token=\(token)&owner_id=\(userId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func searchAudio(token: String,
                     secret: String,
                     q: String,
                     count: Int = 25,
                     offset: Int = 0,
                     completionHandler: @escaping ((_ count: Int,
                                                    _ list: [AudioModel]?,
                                                    _ result: RequestResult) -> Void))
    {
        if let encoded = q.encoded
        {
            let method = "/method/audio.search?access_token=\(token)&q=\(encoded)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
            
            let methodForHash = "/method/audio.search?access_token=\(token)&q=\(q)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
            
            let hash = "\(methodForHash)\(secret)".md5
            
            self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func receiveAudioArtist(token: String,
                            secret: String,
                            artistId: String,
                            count: Int = 5,
                            offset: Int = 0,
                            completionHandler: @escaping ((_ count: Int,
                                                           _ list: [AudioModel]?,
                                                           _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getAudiosByArtist?access_token=\(token)&artist_id=\(artistId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func receiveAlbumArtist(token: String,
                            secret: String,
                            artistId: String,
                            count: Int = 5,
                            offset: Int = 0,
                            completionHandler: @escaping ((_ count: Int,
                                                           _ list: [AlbumModel]?,
                                                           _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getAlbumsByArtist?access_token=\(token)&artist_id=\(artistId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
                
                let list = self.parseAlbumList(albums: items)
                
                completionHandler(count, list, .Success)
            }
        }
    }
    
    func getAudioFromAlbum(token: String,
                           secret: String,
                           ownerId: Int,
                           accessKey: String,
                           albumId: String,
                           completionHandler: @escaping ((_ count: Int,
                                                          _ list: [AudioModel]?,
                                                          _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.get?access_token=\(token)&owner_id=\(ownerId)&album_id=\(albumId)&access_key=\(accessKey)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func getRecommendationsAudio(token: String,
                                 secret: String,
                                 audioId: String,
                                 audioOwnerId: String,
                                 completionHandler: @escaping ((_ count: Int,
                                                                _ list: [AudioModel]?,
                                                                _ result: RequestResult) -> Void))
    {
        let targetAudio = "\(audioOwnerId)_\(audioId)"

        let method = "/method/audio.getRecommendations?access_token=\(token)&target_audio=\(targetAudio)&count=100&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func getCatologAudio(token: String,
                         secret: String,
                         completionHandler: @escaping ((_ catalog: Catalog?,
                                                        _ result: RequestResult) -> Void))
    {
        let method = "/method/catalog.getAudio?access_token=\(token)&v=5.138&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
            
            guard let catalog = param["catalog"] as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            var cat = Catalog()
            var catSections: [CatalogSection] = []
            
            if let defaultSection = catalog["default_section"] as? String {
                cat.defaultSection = defaultSection
            }
            
            if let sections = catalog["sections"] as? NSArray
            {
                sections.forEach { section in
                    if let item = section as? [String: String] {
                        
                        let catalogSection = CatalogSection(
                            id: item["id"],
                            title: item["title"],
                            url: item["url"]
                        )
                        
                        catSections.append(catalogSection)
                    }
                }
            }
            
            cat.sections = catSections
            completionHandler(cat, .Success)
        }
    }
    
    func getCatalogSection(token: String,
                           secret: String,
                           catalogSectionId: String,
                           completionHandler: @escaping ((_ section: Section?,
                                                          _ banners: [CatalogBanner]?,
                                                          _ result: RequestResult) -> Void))
    {
        let method = "/method/catalog.getSection?access_token=\(token)&section_id=\(catalogSectionId)&v=5.138&https=1&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
            
            guard let section = param["section"] as? [String: Any] else {
                completionHandler(nil, nil, .ErrorRequest)
                return
            }
            
            var sectionBlocks: [SectionBlock] = []
            
            if let blocks = section["blocks"] as? NSArray
            {
                blocks.forEach { block in
                    if let item = block as? [String: Any] {
                        
                        var sectionLayout: SectionLayout? = nil
                        var sectionButtons: [SectionButton]? = nil
                        
                        if let layout = item["layout"] as? [String: Any]
                        {
                            sectionLayout = SectionLayout(
                                name: layout["name"] as? String,
                                title: layout["title"] as? String,
                                ownerId: layout["title"] as? Int
                            )
                        }
                        
                        if let buttons = item["buttons"] as? NSArray
                        {
                            sectionButtons = [SectionButton]()
                            
                            buttons.forEach { button in
                                if let button = button as? [String: Any] {
                                    
                                    let sectionButton = SectionButton(
                                        sectionId: button["section_id"] as? String,
                                        title: button["title"] as? String,
                                        refItemsCount: button["ref_items_count"] as? Int,
                                        refLayoutName: button["ref_layout_name"] as? String,
                                        refDataType: button["ref_data_type"] as? String
                                    )
                                    
                                    sectionButtons?.append(sectionButton)
                                }
                            }
                        }
                        
                        let sectionBlock = SectionBlock(
                            id: item["id"] as? String,
                            dataType: item["data_type"] as? String,
                            layout: sectionLayout,
                            buttons: sectionButtons,
                            catalogBannerIds: item["catalog_banner_ids"] as? [Int],
                            nextFrom: item["next_from"] as? String,
                            url: item["url"] as? String,
                            audiosIds: item["audios_ids"] as? [String],
                            playlistsIds: item["playlists_ids"] as? [String]
                        )
                        
                        sectionBlocks.append(sectionBlock)
                    }
                }
            }
            
            let result = Section(
                id: section["id"] as? String,
                title: section["title"] as? String,
                blocks: sectionBlocks,
                nextFrom: section["next_from"] as? String,
                url: section["url"] as? String
            )
            
            var catBanners: [CatalogBanner] = []
            
            if let banners = param["catalog_banners"] as? NSArray {
                
                banners.forEach { item in
                    
                    if let item = item as? [String: Any]
                    {
                        
                        var url: String? = nil
                        var image: String? = nil
                        
                        if let images = item["images"] as? NSArray {
                            
                            if let element = images.lastObject as? [String: Any]
                            {
                                image = element["url"] as? String
                            }
                        }
                        
                        if let click_action = item["click_action"] as? [String: Any] {
                            
                            if let action = click_action["action"] as? [String: Any] {
                                
                                url = action["url"] as? String
                            }
                        }
                        
                        let banner = CatalogBanner(
                            id: item["id"] as? Int,
                            title: item["title"] as? String,
                            text: item["text"] as? String,
                            subtext: item["subtext"] as? String,
                            trackCode: item["track_code"] as? String,
                            imageMode: item["image_mode"] as? String,
                            image: image,
                            url: url
                        )
                        
                        catBanners.append(banner)
                    }
                }
            }
            
            completionHandler(result, catBanners, .Success)
        }
    }
    
    func getButtonTracks(token: String,
                         secret: String,
                         buttonSectionId: String,
                         completionHandler: @escaping ((_ list: [AudioModel]?,
                                                        _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getButtonTracks?access_token=\(token)&id=\(buttonSectionId)&count=100&v=5.138&https=1&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
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
    
    func getAudios(token: String,
                   secret: String,
                   audios: [String],
                   completionHandler: @escaping ((_ list: [AudioModel]?,
                                                  _ result: RequestResult) -> Void))
    {
        let joined = audios.joined(separator: ", ")
        
        if let encoded = joined.encoded
        {
            let method = "/method/audio.getById?access_token=\(token)&audios=\(encoded)&v=5.95&https=1&lang=ru&device_id=\(self.getDeviceId())"
            
            let methodForHash = "/method/audio.getById?access_token=\(token)&audios=\(joined)&v=5.95&https=1&lang=ru&device_id=\(self.getDeviceId())"
            
            let hash = "\(methodForHash)\(secret)".md5
            
            self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
                guard let data = data else {
                    completionHandler(nil, .ErrorInternet)
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
                {
                    completionHandler(nil, .ErrorRequest)
                    return
                }
                
                guard let response = json["response"] as? NSArray else {
                    completionHandler(nil, .ErrorRequest)
                    return
                }
                
                let list = self.parseAudioList(audios: response)
                
                completionHandler(list, .Success)
            }
        }
    }
    
    func getSearchSuggestions(token: String,
                              secret: String,
                              completionHandler: @escaping ((_ list: [Suggestion]?,
                                                             _ result: RequestResult) -> Void))
    {
        let method = "/method/catalog.getAudioSearch?access_token=\(token)&need_blocks=0&v=5.138&https=1&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
            
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
            
            guard let catalog = param["catalog"] as? [String: Any] else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            guard let defaultSection = catalog["default_section"] as? String else {
                completionHandler(nil, .ErrorRequest)
                return
            }
            
            self.getSearchSection(token: token,
                                  secret: secret,
                                  sectionId: defaultSection,
                                  completionHandler: completionHandler)
        }
    }
    
    private func getSearchSection(token: String,
                                  secret: String,
                                  sectionId: String,
                                  completionHandler: @escaping ((_ list: [Suggestion]?,
                                                                 _ result: RequestResult) -> Void))
    {
        let method = "/method/catalog.getSection?access_token=\(token)&section_id=\(sectionId)&v=5.138&https=1&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
            
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
    
    
    /*
     * List
     */
    
    private func parseAudioList(audios: NSArray) -> [AudioModel]
    {
        var list = [AudioModel]()
        
        audios.forEach { it in
            
            if let item = it as? [String: Any]
            {
                if let audioId = item["id"] as? Int64,
                   let audioOwnerId = item["owner_id"] as? Int,
                   let artist = item["artist"] as? String,
                   let title = item["title"] as? String,
                   let streamUrl = item["url"] as? String,
                   let duration = item["duration"] as? Int,
                   let isExplicit = item["is_explicit"] as? Bool,
                   !streamUrl.isEmpty, duration > 0
                {
                    var model = AudioModel()
                    model.audioId = String(audioId)
                    model.audioOwnerId = String(audioOwnerId)
                    model.artist = artist
                    model.title = title
                    model.streamUrl = streamUrl
                    model.duration = Int32(duration)
                    model.isExplicit = isExplicit
                    
                    if let album = item["album"] as? [String: Any],
                       let albumId = album["id"] as? Int64,
                       let albumTitle = album["title"] as? String,
                       let albumOwnerId = album["owner_id"] as? Int,
                       let albumAccessKey = album["access_key"] as? String
                    {
                        model.albumId = String(albumId)
                        model.albumTitle = albumTitle
                        model.albumOwnerId = String(albumOwnerId)
                        model.albumAccessKey = albumAccessKey
                        
                        if let thumb = album["thumb"] as? [String: Any]
                        {
                            model.thumb = thumb["photo_300"] as? String ?? ""
                        }
                    }
                    
                    var artists: [ArtistModel] = []
                    
                    if let main_artists = item["main_artists"] as? NSArray
                    {
                        main_artists.forEach { artist in
                            if let artist = artist as? [String: Any]
                            {
                                let model = ArtistModel(name: artist["name"] as? String ?? "",
                                                        domain: artist["domain"] as? String ?? "",
                                                        id: artist["id"] as? String ?? "",
                                                        featured: false)
                                artists.append(model)
                            }
                        }
                    }
                    
                    if let featured_artists = item["featured_artists"] as? NSArray
                    {
                        featured_artists.forEach { artist in
                            if let artist = artist as? [String: Any]
                            {
                                let model = ArtistModel(name: artist["name"] as? String ?? "",
                                                        domain: artist["domain"] as? String ?? "",
                                                        id: artist["id"] as? String ?? "",
                                                        featured: true)
                                artists.append(model)
                            }
                        }
                    }
                    
                    model.artists = artists
                    list.append(model)
                }
            }
        }
        
        return list
    }
    
    private func parseAlbumList(albums: NSArray) -> [AlbumModel]
    {
        var list: [AlbumModel] = []
        
        albums.forEach { it in
            
            if let item = it as? [String: Any]
            {
                if let albumId = item["id"] as? Int64,
                   let title = item["title"] as? String,
                   let description = item["description"] as? String,
                   let count = item["count"] as? Int,
                   let create_time = item["create_time"] as? Int64,
                   let update_time = item["update_time"] as? Int64,
                   let year = item["year"] as? Int,
                   let owner_id = item["owner_id"] as? Int,
                   let access_key = item["access_key"] as? String
                {
                    var model = AlbumModel()
                    model.albumId = String(albumId)
                    model.title = title
                    model.description = description
                    model.count = count
                    model.create_time = create_time
                    model.update_time = update_time
                    model.year = year
                    model.ownerId = owner_id
                    model.accessKey = access_key
                    
                    if let is_explicit = item["is_explicit"] as? Bool
                    {
                        model.isExplicit = is_explicit
                    }
                    
                    if let thumb = item["photo"] as? [String: Any]
                    {
                        model.thumb = thumb["photo_300"] as? String ?? ""
                    }
                    
                    list.append(model)
                }
            }
        }
        
        return list
    }
}
