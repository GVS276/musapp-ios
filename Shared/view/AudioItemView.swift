//
//  AudioItemView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 20.08.2022.
//

import SwiftUI

struct AudioItemView<M: View>: View
{
    let item: AudioStruct
    let playedId: String?
    let clicked: () -> Void
    
    @ViewBuilder var menuContent: M
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            Button {
                self.clicked()
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
                        
                        Text(item.model.title)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                    }
                }
                .padding(.horizontal, 15)
            }
            .buttonStyle(AudioButtonStyle())
            
            Menu {
                menuContent
            } label: {
                VStack(alignment: .trailing)
                {
                    Image("action_menu")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .frame(width: 16, height: 16)
                        .padding(.trailing, 10)
                    
                    HStack {
                        Text("E")
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 8))
                            .padding(.horizontal, 2)
                            .border(Color("color_text"))
                            .removed(!item.model.isExplicit)
                        
                        Text(item.model.duration.toTime())
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }
                    .padding(.trailing, 15)
                }
            }
        }
        .padding(.vertical, 10)
        .background(item.model.audioId == self.playedId ? Color("color_playing") : Color.clear)
    }
}
