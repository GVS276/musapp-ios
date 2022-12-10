//
//  VKExtensions.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

extension VKRequestSession
{
    func parseAudioList(audios: NSArray) -> [AudioModel]
    {
        var list = [AudioModel]()
        
        audios.forEach { it in
            
            if let item = it as? [String: Any]
            {
                if let audioId = item["id"] as? Int64,
                   let audioOwnerId = item["owner_id"] as? Int,
                   let artist = item["artist"] as? String,
                   let title = item["title"] as? String,
                   let streamUrl = item["url"] as? String,
                   let duration = item["duration"] as? Int,
                   let isExplicit = item["is_explicit"] as? Bool,
                   !streamUrl.isEmpty, duration > 0
                {
                    var model = AudioModel()
                    model.audioId = String(audioId)
                    model.audioOwnerId = String(audioOwnerId)
                    model.artist = artist
                    model.title = title
                    model.streamUrl = streamUrl
                    model.duration = Int32(duration)
                    model.isExplicit = isExplicit
                    
                    if let album = item["album"] as? [String: Any],
                       let albumId = album["id"] as? Int64,
                       let albumTitle = album["title"] as? String,
                       let albumOwnerId = album["owner_id"] as? Int,
                       let albumAccessKey = album["access_key"] as? String
                    {
                        model.albumId = String(albumId)
                        model.albumTitle = albumTitle
                        model.albumOwnerId = String(albumOwnerId)
                        model.albumAccessKey = albumAccessKey
                        
                        if let thumb = album["thumb"] as? [String: Any]
                        {
                            model.thumb = thumb["photo_300"] as? String ?? ""
                        }
                    }
                    
                    var artists: [ArtistModel] = []
                    
                    if let main_artists = item["main_artists"] as? NSArray
                    {
                        main_artists.forEach { artist in
                            if let artist = artist as? [String: Any]
                            {
                                let model = ArtistModel(name: artist["name"] as? String ?? "",
                                                        domain: artist["domain"] as? String ?? "",
                                                        id: artist["id"] as? String ?? "",
                                                        featured: false)
                                artists.append(model)
                            }
                        }
                    }
                    
                    if let featured_artists = item["featured_artists"] as? NSArray
                    {
                        featured_artists.forEach { artist in
                            if let artist = artist as? [String: Any]
                            {
                                let model = ArtistModel(name: artist["name"] as? String ?? "",
                                                        domain: artist["domain"] as? String ?? "",
                                                        id: artist["id"] as? String ?? "",
                                                        featured: true)
                                artists.append(model)
                            }
                        }
                    }
                    
                    model.artists = artists
                    list.append(model)
                }
            }
        }
        
        return list
    }

    func parseAlbumList(albums: NSArray) -> [AlbumModel]
    {
        var list: [AlbumModel] = []
        
        albums.forEach { it in
            
            if let item = it as? [String: Any]
            {
                if let albumId = item["id"] as? Int64,
                   let title = item["title"] as? String,
                   let description = item["description"] as? String,
                   let count = item["count"] as? Int,
                   let create_time = item["create_time"] as? Int64,
                   let update_time = item["update_time"] as? Int64,
                   let year = item["year"] as? Int,
                   let owner_id = item["owner_id"] as? Int,
                   let access_key = item["access_key"] as? String
                {
                    var model = AlbumModel()
                    model.albumId = String(albumId)
                    model.title = title
                    model.description = description
                    model.count = count
                    model.create_time = create_time
                    model.update_time = update_time
                    model.year = year
                    model.ownerId = owner_id
                    model.accessKey = access_key
                    
                    if let is_explicit = item["is_explicit"] as? Bool
                    {
                        model.isExplicit = is_explicit
                    }
                    
                    if let thumb = item["photo"] as? [String: Any]
                    {
                        model.thumb = thumb["photo_300"] as? String ?? ""
                    }
                    
                    list.append(model)
                }
            }
        }
        
        return list
    }
    
    func parseSection(item: [String: Any]) -> Section
    {
        var blocks = [SectionBlock]()
        
        if let listBlocks = item["blocks"] as? NSArray
        {
            listBlocks.forEach { block in
                
                if let block = block as? [String: Any] {
                    
                    var sectionLayout: SectionLayout? = nil
                    var sectionButtons: [SectionButton]? = nil
                    
                    if let layout = block["layout"] as? [String: Any]
                    {
                        sectionLayout = SectionLayout(
                            name: layout["name"] as? String,
                            title: layout["title"] as? String,
                            ownerId: layout["title"] as? Int
                        )
                    }
                    
                    if let buttons = block["buttons"] as? NSArray
                    {
                        sectionButtons = [SectionButton]()
                        
                        buttons.forEach { button in
                            if let button = button as? [String: Any] {
                                
                                let sectionButton = SectionButton(
                                    blockId: button["block_id"] as? String,
                                    sectionId: button["section_id"] as? String,
                                    title: button["title"] as? String,
                                    refItemsCount: button["ref_items_count"] as? Int,
                                    refLayoutName: button["ref_layout_name"] as? String,
                                    refDataType: button["ref_data_type"] as? String
                                )
                                
                                sectionButtons?.append(sectionButton)
                            }
                        }
                    }
                    
                    let sectionBlock = SectionBlock(
                        id: block["id"] as? String,
                        dataType: block["data_type"] as? String,
                        layout: sectionLayout,
                        buttons: sectionButtons,
                        nextFrom: block["next_from"] as? String,
                        url: block["url"] as? String,
                        catalogBannerIds: block["catalog_banner_ids"] as? [Int],
                        audiosIds: block["audios_ids"] as? [String],
                        playlistsIds: block["playlists_ids"] as? [String],
                        artists_ids: block["artists_ids"] as? [String],
                        group_ids: block["group_ids"] as? [Int]
                    )
                    
                    blocks.append(sectionBlock)
                }
            }
        }
        
        let section = Section(
            id: item["id"] as? String,
            title: item["title"] as? String,
            blocks: blocks,
            nextFrom: item["next_from"] as? String,
            url: item["url"] as? String
        )
        
        return section
    }
    
    func parseBanners(listBanners: NSArray) -> [CatalogBanner]
    {
        var banners = [CatalogBanner]()
        
        listBanners.forEach { item in
            
            if let item = item as? [String: Any]
            {
                
                var url: String? = nil
                var image: String? = nil
                
                if let images = item["images"] as? NSArray {
                    
                    if let element = images.lastObject as? [String: Any]
                    {
                        image = element["url"] as? String
                    }
                }
                
                if let click_action = item["click_action"] as? [String: Any] {
                    
                    if let action = click_action["action"] as? [String: Any] {
                        
                        url = action["url"] as? String
                    }
                }
                
                let banner = CatalogBanner(
                    id: item["id"] as? Int,
                    title: item["title"] as? String,
                    text: item["text"] as? String,
                    subtext: item["subtext"] as? String,
                    trackCode: item["track_code"] as? String,
                    imageMode: item["image_mode"] as? String,
                    image: image,
                    url: url
                )
                
                banners.append(banner)
            }
        }
        
        return banners
    }
}
