//
//  AudioModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

struct ArtistModel: Codable, Identifiable
{
    var name: String = ""
    var domain: String = ""
    var id: String = ""
    var featured: Bool = false
}

struct AudioModel
{
    var audioId: String = ""
    var artist: String = ""
    var title: String = ""
    var streamUrl: String = ""
    var downloadUrl: String = ""
    var duration: Int32 = 0
    var isDownloaded: Int32 = 0
    var isExplicit: Bool = false
    var thumb: String = ""
    var albumId: String = ""
    var albumTitle: String = ""
    var artists: [ArtistModel] = []
    var timestamp: Int64 = 0
}
