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
            
            self.createAudioList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
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
                
                self.createAudioList(data: data) { count, list in
                    if count == -1 {
                        completionHandler(0, nil, .ErrorRequest)
                    } else {
                        completionHandler(count, list, .Success)
                    }
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
            
            self.createAudioList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
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
            
            self.createAlbumList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
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
            
            self.createAudioList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
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
            
            self.createAudioList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
            }
        }
    }
    
    func getPlaylists(token: String,
                      secret: String,
                      userId: Int64,
                      count: Int = 5,
                      offset: Int = 0,
                      completionHandler: @escaping ((_ count: Int,
                                                     _ list: [PlaylistModel]?,
                                                     _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getPlaylists?access_token=\(token)&owner_id=\(userId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
        let hash = "\(method)\(secret)".md5
        
        self.requestSession(urlString: "https://api.vk.com\(method)&sig=\(hash)", parameters: nil) { data in
            guard let data = data else {
                completionHandler(0, nil, .ErrorInternet)
                return
            }
            
            self.createPlayList(data: data) { count, list in
                if count == -1 {
                    completionHandler(0, nil, .ErrorRequest)
                } else {
                    completionHandler(count, list, .Success)
                }
            }
        }
    }
    
    /*
     * List
     */
    
    private func createAudioList(data: Data, result: (_ count: Int, _ list: [AudioModel]) -> Void)
    {
        var list: [AudioModel] = []
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
        {
            result(-1, list)
            return
        }
        
        guard let param = json["response"] as? [String: Any] else {
            result(-1, list)
            return
        }
        
        guard let count = param["count"] as? Int else {
            result(-1, list)
            return
        }
        
        guard let items = param["items"] as? NSArray else {
            result(-1, list)
            return
        }
        
        if count > 0 {
            items.forEach { it in
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
        }
        
        result(count, list)
    }
    
    private func createAlbumList(data: Data, result: (_ count: Int, _ list: [AlbumModel]) -> Void)
    {
        var list: [AlbumModel] = []
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
        {
            result(-1, list)
            return
        }
        
        guard let param = json["response"] as? [String: Any] else {
            result(-1, list)
            return
        }
        
        guard let count = param["count"] as? Int else {
            result(-1, list)
            return
        }
        
        guard let items = param["items"] as? NSArray else {
            result(-1, list)
            return
        }
        
        if count > 0 {
            items.forEach { it in
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
        }
        
        result(count, list)
    }
    
    private func createPlayList(data: Data, result: (_ count: Int, _ list: [PlaylistModel]) -> Void)
    {
        var list: [PlaylistModel] = []
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else
        {
            result(-1, list)
            return
        }
        
        guard let param = json["response"] as? [String: Any] else {
            result(-1, list)
            return
        }
        
        guard let count = param["count"] as? Int else {
            result(-1, list)
            return
        }
        
        guard let items = param["items"] as? NSArray else {
            result(-1, list)
            return
        }
        
        if count > 0 {
            items.forEach { it in
                if let item = it as? [String: Any]
                {
                    if let title = item["title"] as? String,
                       let description = item["description"] as? String,
                       let count = item["count"] as? Int,
                       let update_time = item["update_time"] as? Int64
                    {
                        var model = PlaylistModel()
                        model.title = title
                        model.description = description
                        model.count = count
                        model.update_time = update_time
                        
                        if let year = item["year"] as? Int
                        {
                            model.year = year
                        }
                        
                        if let thumb = item["photo"] as? [String: Any]
                        {
                            model.thumb = thumb["photo_300"] as? String ?? ""
                        }
                        
                        if let original = item["original"] as? [String: Any]
                        {
                            let id = original["playlist_id"] as? Int ?? 0
                            model.id = String(id)
                            model.ownerId = original["owner_id"] as? Int ?? 0
                            model.accessKey = original["access_key"] as? String ?? ""
                        } else {
                            let id = item["id"] as? Int ?? 0
                            model.id = String(id)
                            model.ownerId = item["owner_id"] as? Int ?? 0
                            model.accessKey = item["access_key"] as? String ?? ""
                        }
                        
                        list.append(model)
                    }
                }
            }
        }
        
        result(count, list)
    }
}
