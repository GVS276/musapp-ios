//
//  AlbumItemView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.09.2022.
//

import SwiftUI

struct AlbumItemView: View
{
    let item: AlbumModel
    let clicked: () -> Void
    
    var body: some View
    {
        Button {
            clicked()
        } label: {
            HStack(spacing: 15)
            {
                ThumbView(url: item.thumb, albumId: item.albumId)
                
                VStack(spacing: 2)
                {
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    let strYear = String(item.year)
                    let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                    
                    HStack(spacing: 5)
                    {
                        Image("action_explicit")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color("color_text"))
                            .frame(width: 14, height: 14)
                            .removed(!item.isExplicit)
                        
                        Text("\(strYear) • \(strCount)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }
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
