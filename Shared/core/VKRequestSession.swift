//
//  VKRequestSession.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

import UIKit

enum RequestResult {
    case ErrorInternet
    case ErrorRequest
    case Success
}

class VKRequestSession
{
    private let USER_AGENT = "VKAndroidApp/5.52-4543 (Android 5.1.1; SDK 22; x86_64; unknown Android SDK built for x86_64; en; 320x240)"
    
    private final var deviceId: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    func requestSession(urlString: String,
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
    
    func methodLine(method: String,
                    token: String,
                    param: [String],
                    needBlocks: Bool,
                    apiVer: String,
                    lang: String) -> String
    {
        
        let j = param.isEmpty ? "" : "&\(param.joined(separator: "&"))"
        
        let m = "/method/\(method)?access_token=\(token)"
        
        let blocks = needBlocks ? "1" : "0"
        
        return "\(m)\(j)&need_blocks=\(blocks)&v=\(apiVer)&https=1&lang=\(lang)&device_id=\(deviceId)"
        
    }
}
