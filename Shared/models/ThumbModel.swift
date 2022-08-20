//
//  ThumbModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 20.08.2022.
//

import Foundation

class ThumbModel: ObservableObject
{
    static let shared = ThumbModel()
    private var list = [String: Data]()
    
    func receiveThumbData(urlString: String, albumId: String)
    {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                if !self.list.contains(where: {$0.key == albumId})
                {
                    self.list[albumId] = data
                }
            }
        }
        
        task.resume()
    }
    
    func getThumbData(albumId: String) -> Data?
    {
        if self.list.contains(where: {$0.key == albumId})
        {
            return self.list[albumId]
        }
        return nil
    }
}
