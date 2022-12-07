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
        HStack(spacing: 15)
        {
            ThumbView(url: item.thumb, albumId: item.albumId)
            
            VStack(spacing: 2)
            {
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                let strYear = String(item.year)
                let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                
                Text("\(strYear) • \(strCount)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
            }
            
            Image("action_explicit")
                .resizable()
                .frame(width: 15, height: 15)
                .removed(!item.isExplicit)
            
            Image("action_next")
                .renderingMode(.template)
                .foregroundColor(Color("color_text"))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            clicked()
        }
    }
}
