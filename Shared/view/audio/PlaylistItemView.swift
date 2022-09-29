//
//  PlaylistItemView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 29.09.2022.
//

import SwiftUI

struct PlaylistItemView: View
{
    let item: PlaylistModel
    let clicked: () -> Void
    
    var body: some View
    {
        Button {
            clicked()
        } label: {
            HStack(spacing: 15)
            {
                ThumbView(url: item.thumb, albumId: item.id, big: false)
                
                VStack(spacing: 2)
                {
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                    let subTitle = item.year > 0 ? "\(String(item.year)) • \(strCount)" : "\(strCount)"
                    
                    Text(subTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
        }
        .buttonStyle(AudioButtonStyle())
    }
}

