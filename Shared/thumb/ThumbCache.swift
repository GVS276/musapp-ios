//
//  ThumbCache.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.08.2022.
//

import UIKit

protocol Thumb
{
    subscript (albumId: String) -> UIImage? { get set }
}

struct ThumbCache: Thumb
{
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    private func getImage(albumId: String) -> UIImage?
    {
        guard !albumId.isEmpty else {
            print("Thumb: id empty")
            return nil
        }
        
        if let image = self.cache.object(forKey: albumId as NSString)
        {
            print("Thumb: cached from RAM")
            return image
        }
        
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                guard let image = UIImage(contentsOfFile: fileUrl.path) else {
                    return nil
                }
                
                print("Thumb: cached from Disk")
                self.cache.setObject(image, forKey: albumId as NSString)
                return image
            }
        }
        
        print("Thumb: not cache")
        return nil
    }
    
    subscript (albumId: String) -> UIImage?
    {
        get {
            getImage(albumId: albumId)
        }
        
        set {
            newValue == nil ?
            cache.removeObject(forKey: albumId as NSString) :
            cache.setObject(newValue!, forKey: albumId as NSString)
        }
    }
}

class ThumbCacheObj {
    static var cache: Thumb = ThumbCache()
}
