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
    let item: AudioStruct
    let source: AudioItemSource
    let playedId: String?
    let clicked: (_ type: AudioItemClick) -> Void
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            Button {
                self.clicked(.Item)
            } label: {
                HStack(spacing: 15)
                {
                    if (source != .AudioFromAlbum)
                    {
                        ThumbView(url: item.model.thumb, albumId: item.model.albumId, big: false)
                    }
                    
                    VStack(spacing: 2)
                    {
                        let title = source == .AudioFromAlbum ? item.model.title : item.model.artist
                        let subTitle = source == .AudioFromAlbum ? item.model.duration.toTime() : item.model.title
                        
                        Text(title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .removed(item.model.artist.isEmpty)
                        
                        HStack(spacing: 5)
                        {
                            Image("action_explicit")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color("color_text"))
                                .frame(width: 14, height: 14)
                                .removed(!item.model.isExplicit)
                            
                            Text(subTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("color_text"))
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .removed(item.model.title.isEmpty)
                        }
                    }
                }
                .padding(.leading, 15)
            }
            .buttonStyle(AudioButtonStyle())
            
            Button {
                self.clicked(.Menu)
            } label: {
                Image("action_menu")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }
        }
        .padding(.vertical, 10)
        .background(item.model.audioId == self.playedId ? Color("color_playing") : Color.clear)
    }
}
