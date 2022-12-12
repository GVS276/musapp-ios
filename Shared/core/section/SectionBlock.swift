//
//  SectionBlock.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

struct SectionBlock
{
    let id: String?
    let dataType: String?
    let layout: SectionLayout?
    let buttons: [SectionButton]
    let nextFrom: String?
    let url: String?
    let banners: [CatalogBanner]
    let audios: [AudioModel]
    let playlists: [AlbumModel]
}
