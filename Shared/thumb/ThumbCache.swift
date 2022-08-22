//
//  ThumbCache.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.08.2022.
//

import UIKit
import SwiftUI

protocol Thumb {
    subscript(albumId: String) -> UIImage? { get set }
}

struct ThumbCache: Thumb {
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    // TEST
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
        
        cache.setObject(image, forKey: albumId as NSString)
    }
    
    private func remove(albumId: String)
    {
        if let fileUrl = UIFileUtils.getThumbFilePath(fileName: "\(albumId).jpg")
        {
            if UIFileUtils.existFile(fileUrl: fileUrl) {
                UIFileUtils.removeFile(fileUrl: fileUrl)
            }
        }
        
        cache.removeObject(forKey: albumId as NSString)
    }
    
    private func getImage(albumId: String) -> UIImage?
    {
        if let image = cache.object(forKey: albumId as NSString)
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
                cache.setObject(image, forKey: albumId as NSString)
                return image
            }
        }
        
        print("Thumb: not cache")
        return nil
    }
    //--------
    
    subscript(albumId: String) -> UIImage? {
        get {
            getImage(albumId: albumId)
            //cache.object(forKey: albumId as NSString)
        }
        set {
            //newValue == nil ?
            //cache.removeObject(forKey: albumId as NSString) :
            //cache.setObject(newValue!, forKey: albumId as NSString)
            newValue == nil ?
            remove(albumId: albumId) :
            create(albumId: albumId, image: newValue!)
        }
    }
}

struct DefaultThumbKey: EnvironmentKey {
    static var defaultValue: Thumb = ThumbCache()
}

extension EnvironmentValues {
    var defaultCache: Thumb {
        get { self[DefaultThumbKey.self] }
        set { self[DefaultThumbKey.self] = newValue }
    }
}
