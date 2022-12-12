//
//  VKExtensions.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.12.2022.
//

import Foundation

extension VKRequestSession
{
    func parseAudioList(audios: [[String: Any]]) -> [AudioModel]
    {
        var list = [AudioModel]()
        
        for audio in audios {
            
            if let model = self.convertToAudioModel(item: audio) {
                list.append(model)
            }
            
        }
        
        return list
    }
    
    func parseAlbumList(albums: [[String: Any]]) -> [AlbumModel]
    {
        var list: [AlbumModel] = []
        
        for album in albums {
            
            if let model = self.convertToAlbumModel(item: album) {
                list.append(model)
            }
            
        }
        
        return list
    }
    
    func parseSection(param: [String: Any], item: [String: Any], count: Int) -> Section
    {
        let banners = param["catalog_banners"] as? [[String: Any]]
        
        let audios = param["audios"] as? [[String: Any]]
        
        let playlists = param["playlists"] as? [[String: Any]]
        
        var blocks = [SectionBlock]()
        
        if let listBlocks = item["blocks"] as? [[String: Any]]
        {
            for block in listBlocks {
                
                // парсим layout под блок
                var sectionLayout: SectionLayout? = nil
                
                if let layout = block["layout"] as? [String: Any]
                {
                    sectionLayout = SectionLayout(
                        name: layout["name"] as? String,
                        title: layout["title"] as? String,
                        ownerId: layout["owner_id"] as? Int
                    )
                }
                
                // парсим buttons под блок
                var sectionButtons = [SectionButton]()
                
                if let buttons = block["buttons"] as? [[String: Any]]
                {
                    for button in buttons {
                        
                        var buttonAction: SectionButtonAction? = nil
                        
                        if let action = button["action"] as? [String: Any]
                        {
                            buttonAction = SectionButtonAction(
                                type: action["type"] as? String,
                                target: action["target"] as? String,
                                url: action["url"] as? String
                            )
                        }
                        
                        let sectionButton = SectionButton(
                            action: buttonAction,
                            blockId: button["block_id"] as? String,
                            sectionId: button["section_id"] as? String,
                            title: button["title"] as? String,
                            refItemsCount: button["ref_items_count"] as? Int,
                            refLayoutName: button["ref_layout_name"] as? String,
                            refDataType: button["ref_data_type"] as? String
                        )
                        
                        sectionButtons.append(sectionButton)
                    }
                }
                
                // парсим баннеры под блок
                var listBanner = [CatalogBanner]()
                
                if let banners = banners
                {
                    if let bannerIds = block["catalog_banner_ids"] as? [Int]
                    {
                        for id in bannerIds {
                            
                            let check = banners.first { banner in
                                
                                guard let bannerId = banner["id"] as? Int else {
                                    return false
                                }
                                
                                return id == bannerId
                            }
                            
                            if let check = check {
                                let model = self.convertToCatalogBanner(item: check)
                                listBanner.append(model)
                            }
                        }
                    }
                }
                
                // парсим список аудио под блок
                var listAudio = [AudioModel]()
                
                if let audios = audios
                {
                    if let audiosIds = block["audios_ids"] as? [String]
                    {
                        for id in audiosIds {
                            
                            let check = audios.first { audio in
                                
                                guard let audioId = audio["id"] as? Int else {
                                    return false
                                }
                                
                                guard let audioOwnerId = audio["owner_id"] as? Int else {
                                    return false
                                }
                                
                                return id == "\(audioOwnerId)_\(audioId)"
                            }
                            
                            if let check = check {
                                if let model = self.convertToAudioModel(item: check) {
                                    listAudio.append(model)
                                }
                            }
                        }
                    }
                }
                
                // парсим список плейлистов под блок
                var listPlaylist = [AlbumModel]()
                
                if let playlists = playlists
                {
                    if let playlistsIds = block["playlists_ids"] as? [String]
                    {
                        for id in playlistsIds {
                            
                            let check = playlists.first { playlist in
                                
                                guard let playlistId = playlist["id"] as? Int else {
                                    return false
                                }
                                
                                guard let playlistOwnerId = playlist["owner_id"] as? Int else {
                                    return false
                                }
                                
                                return id == "\(playlistOwnerId)_\(playlistId)"
                            }
                            
                            if let check = check {
                                if let model = self.convertToAlbumModel(item: check) {
                                    listPlaylist.append(model)
                                }
                            }
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
                    banners: listBanner,
                    audios: listAudio.count >= count ? Array(listAudio.prefix(count)) : listAudio,
                    playlists: listPlaylist.count >= count ? Array(listPlaylist.prefix(count)) : listPlaylist
                )
                
                blocks.append(sectionBlock)
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
    
    func convertToCatalogBanner(item: [String: Any]) -> CatalogBanner
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
        
        return banner
    }
    
    func convertToAudioModel(item: [String: Any]) -> AudioModel?
    {
        guard let id = item["id"] as? Int,
              let ownerId = item["owner_id"] as? Int,
              let artist = item["artist"] as? String,
              let title = item["title"] as? String,
              let url = item["url"] as? String,
              let duration = item["duration"] as? Int,
              let isExplicit = item["is_explicit"] as? Bool
        else {
            return nil
        }
        
        guard let album = item["album"] as? [String: Any],
              let albumId = album["id"] as? Int64,
              let albumTitle = album["title"] as? String,
              let albumOwnerId = album["owner_id"] as? Int,
              let albumAccessKey = album["access_key"] as? String
        else {
            return nil
        }
        
        guard !url.isEmpty else {
            return nil
        }
        
        var model = AudioModel()
        model.audioId = String(id)
        model.audioOwnerId = String(ownerId)
        model.artist = artist
        model.title = title
        model.streamUrl = url
        model.duration = Int32(duration)
        model.isExplicit = isExplicit
        
        model.albumId = String(albumId)
        model.albumTitle = albumTitle
        model.albumOwnerId = String(albumOwnerId)
        model.albumAccessKey = albumAccessKey
        
        if let thumb = album["thumb"] as? [String: Any]
        {
            if let photo = thumb["photo_600"] as? String
            {
                model.thumb = photo
            }
            else if let photo = thumb["photo_300"] as? String {
                model.thumb = photo
            }
        }
        
        if let main_artists = item["main_artists"] as? [[String: Any]]
        {
            for artist in main_artists
            {
                let artistModel = ArtistModel(
                    name: artist["name"] as? String ?? "",
                    domain: artist["domain"] as? String ?? "",
                    id: artist["id"] as? String ?? "",
                    featured: false
                )
                
                model.artists.append(artistModel)
            }
        }
        
        if let featured_artists = item["featured_artists"] as? [[String: Any]]
        {
            for artist in featured_artists
            {
                let artistModel = ArtistModel(
                    name: artist["name"] as? String ?? "",
                    domain: artist["domain"] as? String ?? "",
                    id: artist["id"] as? String ?? "",
                    featured: true
                )
                
                model.artists.append(artistModel)
            }
        }
        
        return model
    }
    
    func convertToAlbumModel(item: [String: Any]) -> AlbumModel?
    {
        guard let albumId = item["id"] as? Int64,
           let title = item["title"] as? String,
           let description = item["description"] as? String,
           let count = item["count"] as? Int,
           let create_time = item["create_time"] as? Int64,
           let update_time = item["update_time"] as? Int64,
           let owner_id = item["owner_id"] as? Int,
           let access_key = item["access_key"] as? String
        else {
           return nil
        }
        
        var model = AlbumModel()
        model.albumId = String(albumId)
        model.title = title
        model.description = description
        model.count = count
        model.create_time = create_time
        model.update_time = update_time
        model.ownerId = owner_id
        model.accessKey = access_key
        
        if let year = item["year"] as? Int
        {
            model.year = year
        }
        
        if let is_explicit = item["is_explicit"] as? Bool
        {
            model.isExplicit = is_explicit
        }
        
        if let thumb = item["photo"] as? [String: Any]
        {
            if let photo = thumb["photo_600"] as? String
            {
                model.thumb = photo
            }
            else if let photo = thumb["photo_300"] as? String {
                model.thumb = photo
            }
        }
        
        return model
    }
}
