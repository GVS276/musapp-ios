//
//  CatalogVideo.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

struct CatalogVideo {
    let id: Int?
    let ownerId: Int?
    let ovId: String?
    let title: String?
    let description: String?
    let type: String?
    let date: Int?
    let duration: Int?
    let playerUrl: String? // VK player
    let imageUrl: String? // size 320x240 - thumb video
    let files: [String: String]? // mp4_144, mp4_240, mp4_360, mp4_480, mp4_720, mp4_1080, hls
    let trackCode: String?
    let uvStatsPlace: String?
    let releaseDate: String?
    let isExplicit: Bool
    let artists: [ArtistModel]
}
