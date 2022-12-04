//
//  PlaylistModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 03.10.2022.
//

import Foundation

struct PlaylistOriginal: Codable
{
    var id: String = ""
    var ownerId: String = ""
    var accessKey: String = ""
}

struct PlaylistModel: Identifiable
{
    var id: String = ""
    var ownerId: String = ""
    var accessKey: String = ""
    var title: String = ""
    var description: String = ""
    var thumb: String = ""
    var count: Int32 = 0
    var year: Int32 = 0
    var original: PlaylistOriginal? = nil
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}
