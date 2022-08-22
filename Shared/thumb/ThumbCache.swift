//
//  ThumbCache.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.08.2022.
//

import UIKit

class ThumbCache
{
    static let shared = ThumbCache()
    
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    private func create(albumId: String, image: UIImage)
    {
        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                UIFileUtils.removeFile(fileUrl: fileUrl)
            }
            
            UIFileUtils.createFile(path: fileUrl.path, data: data)
        }
        
        self.cache.setObject(image, forKey: albumId as NSString)
    }
    
    private func remove(albumId: String)
    {
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                UIFileUtils.removeFile(fileUrl: fileUrl)
            }
        }
        
        self.cache.removeObject(forKey: albumId as NSString)
    }
    
    func exist(albumId: String) -> Bool
    {
        if self.cache.object(forKey: albumId as NSString) != nil
        {
            return true
        }
        
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            return UIFileUtils.existFile(fileUrl: fileUrl)
        }
        
        return false
    }
    
    func getImage(albumId: String) -> UIImage?
    {
        if let image = self.cache.object(forKey: albumId as NSString)
        {
            print("Thumb: cached from RAM")
            return image
        }
        
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                guard let data = try? Data(contentsOf: fileUrl) else {
                    return nil
                }
                
                guard let image = UIImage(data: data) else {
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
    
    func setImage(albumId: String, image: UIImage?)
    {
        if let image = image
        {
            self.create(albumId: albumId, image: image)
        } else {
            self.remove(albumId: albumId)
        }
    }
}
