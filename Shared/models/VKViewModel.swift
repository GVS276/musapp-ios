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

class VKViewModel: ObservableObject
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
                      completionHandler: @escaping ((_ list: [AudioStruct]?, _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.get?access_token=\(token)&owner_id=\(userId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
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
            
            var list: [AudioStruct] = []
            
            if let param = json["response"] as? [String: Any], let items = param["items"] as? NSArray
            {
                items.forEach { it in
                    if let item = it as? [String: Any]
                    {
                        if let audioId = item["id"] as? Int64,
                           let artist = item["artist"] as? String,
                           let title = item["title"] as? String,
                           let streamUrl = item["url"] as? String,
                           let duration = item["duration"] as? Int
                        {
                            var model = AudioModel()
                            model.audioId = String(audioId)
                            model.artist = artist
                            model.title = title
                            model.streamUrl = streamUrl
                            model.downloadUrl = ""
                            model.duration = Int32(duration)
                            
                            list.append(AudioStruct(model: model))
                        }
                    }
                }
            }
            
            completionHandler(list, .Success)
        }
    }
    
    func searchAudio(token: String,
                     secret: String,
                     q: String,
                     count: Int = 25,
                     offset: Int = 0,
                     completionHandler: @escaping ((_ list: [AudioStruct]?, _ result: RequestResult) -> Void))
    {
        if let encoded = q.encoded
        {
            let method = "/method/audio.search?access_token=\(token)&q=\(encoded)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
            
            let methodForHash = "/method/audio.search?access_token=\(token)&q=\(q)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
            
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
                
                var list: [AudioStruct] = []
                
                if let param = json["response"] as? [String: Any], let items = param["items"] as? NSArray
                {
                    items.forEach { it in
                        if let item = it as? [String: Any]
                        {
                            if let audioId = item["id"] as? Int64,
                               let artist = item["artist"] as? String,
                               let title = item["title"] as? String,
                               let streamUrl = item["url"] as? String,
                               let duration = item["duration"] as? Int
                            {
                                var model = AudioModel()
                                model.audioId = String(audioId)
                                model.artist = artist
                                model.title = title
                                model.streamUrl = streamUrl
                                model.downloadUrl = ""
                                model.duration = Int32(duration)
                                
                                list.append(AudioStruct(model: model))
                            }
                        }
                    }
                }
                
                completionHandler(list, .Success)
            }
        }
    }
    
    func recommendationsAudio(token: String,
                              secret: String,
                              userId: Int64,
                              count: Int = 25,
                              offset: Int = 0,
                              completionHandler: @escaping ((_ list: [AudioStruct]?, _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getRecommendations?access_token=\(token)&user_id=\(userId)&count=\(count)&offset=\(offset)&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
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
            
            var list: [AudioStruct] = []
            
            if let param = json["response"] as? [String: Any], let items = param["items"] as? NSArray
            {
                items.forEach { it in
                    if let item = it as? [String: Any]
                    {
                        if let audioId = item["id"] as? Int64,
                           let artist = item["artist"] as? String,
                           let title = item["title"] as? String,
                           let streamUrl = item["url"] as? String,
                           let duration = item["duration"] as? Int
                        {
                            var model = AudioModel()
                            model.audioId = String(audioId)
                            model.artist = artist
                            model.title = title
                            model.streamUrl = streamUrl
                            model.downloadUrl = ""
                            model.duration = Int32(duration)
                            
                            list.append(AudioStruct(model: model))
                        }
                    }
                }
            }
            
            completionHandler(list, .Success)
        }
    }
    
    func popularAudio(token: String,
                      secret: String,
                      completionHandler: @escaping ((_ list: [AudioStruct]?, _ result: RequestResult) -> Void))
    {
        let method = "/method/audio.getRecommendations?access_token=\(token)&count=100&v=5.95&https=1&need_blocks=0&lang=ru&device_id=\(self.getDeviceId())"
        
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
            
            var list: [AudioStruct] = []
            
            if let param = json["response"] as? [String: Any], let items = param["items"] as? NSArray
            {
                items.forEach { it in
                    if let item = it as? [String: Any]
                    {
                        if let audioId = item["id"] as? Int64,
                           let artist = item["artist"] as? String,
                           let title = item["title"] as? String,
                           let streamUrl = item["url"] as? String,
                           let duration = item["duration"] as? Int
                        {
                            var model = AudioModel()
                            model.audioId = String(audioId)
                            model.artist = artist
                            model.title = title
                            model.streamUrl = streamUrl
                            model.downloadUrl = ""
                            model.duration = Int32(duration)
                            
                            list.append(AudioStruct(model: model))
                        }
                    }
                }
            }
            
            completionHandler(list, .Success)
        }
    }
}
