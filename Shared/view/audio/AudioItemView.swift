//
//  AudioItemView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 20.08.2022.
//

import SwiftUI

enum AudioItemClick
{
    case Item
    case Menu
}

enum AudioItemSource
{
    case AudioFromAlbum
    case OtherAudio
}

struct AudioItemView: View
{
    let item: AudioModel
    let source: AudioItemSource
    let playedId: String?
    let clicked: (_ type: AudioItemClick) -> Void
    
    var body: some View
    {
        HStack(spacing: 15)
        {
            if (source != .AudioFromAlbum)
            {
                ThumbView(url: item.thumb, albumId: item.albumId)
            }
            
            VStack(spacing: 2)
            {
                let title = source == .AudioFromAlbum ? item.title : item.artist
                let subTitle = source == .AudioFromAlbum ? item.duration.toTime() : item.title
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .removed(item.artist.isEmpty)
                
                
                Text(subTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .removed(item.title.isEmpty)
            }
            
            Image("action_explicit")
                .resizable()
                .frame(width: 15, height: 15)
                .removed(!item.isExplicit)
            
            Image("action_menu")
                .renderingMode(.template)
                .foregroundColor(Color("color_text"))
                .padding(.trailing, 15)
                .padding(.vertical, 10)
                .onTapGesture {
                    self.clicked(.Menu)
                }
        }
        .padding(.vertical, 10)
        .padding(.leading, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            self.clicked(.Item)
        }
    }
}
