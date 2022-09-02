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

struct AudioItemView: View
{
    let item: AudioStruct
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
                    ThumbView(url: item.model.thumb, albumId: item.model.albumId, big: false)
                    
                    VStack
                    {
                        Text(item.model.artist)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                            .removed(item.model.artist.isEmpty)
                        
                        Text(item.model.title)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                            .removed(item.model.title.isEmpty)
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
