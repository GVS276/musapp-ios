//
//  AudioModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

struct PlaylistModel: Identifiable
{
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var thumb: String = ""
    var count: Int = 0
    var update_time: Int64 = 0
    var year: Int = 0
    var ownerId: Int = 0
    var accessKey: String = ""
}

struct AlbumModel: Identifiable
{
    let id = UUID().uuidString
    var albumId: String = ""
    var title: String = ""
    var description: String = ""
    var thumb: String = ""
    var count: Int = 0
    var create_time: Int64 = 0
    var update_time: Int64 = 0
    var year: Int = 0
    var ownerId: Int = 0
    var accessKey: String = ""
    var isExplicit: Bool = false
}

struct ArtistModel: Codable, Identifiable
{
    var name: String = ""
    var domain: String = ""
    var id: String = ""
    var featured: Bool = false
}

struct AudioModel: Identifiable, Equatable
{
    let id = UUID().uuidString
    var audioId: String = ""
    var audioOwnerId: String = ""
    var artist: String = ""
    var title: String = ""
    var streamUrl: String = ""
    var duration: Int32 = 0
    var isDownloaded: Bool = false
    var isExplicit: Bool = false
    var thumb: String = ""
    var albumId: String = ""
    var albumTitle: String = ""
    var albumOwnerId: String = ""
    var albumAccessKey: String = ""
    var artists: [ArtistModel] = []
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    
    static func == (lhs: AudioModel, rhs: AudioModel) -> Bool {
        return lhs.id == rhs.id
    }
}
