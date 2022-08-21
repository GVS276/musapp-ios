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
    
    subscript(albumId: String) -> UIImage? {
        get {
            cache.object(forKey: albumId as NSString)
        }
        set {
            newValue == nil ?
            cache.removeObject(forKey: albumId as NSString) :
            cache.setObject(newValue!, forKey: albumId as NSString)
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
