//
//  PlaylistItemView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.12.2022.
//

import SwiftUI

struct PlaylistItemView: View
{
    let item: AlbumModel
    let large: Bool
    let clicked: () -> Void
    
    var body: some View
    {
        if large {
            largeView()
        } else {
            smallView()
        }
    }
    
    private func smallView() -> some View
    {
        HStack(spacing: 15)
        {
            ThumbView(url: item.thumb, albumId: item.albumId, size: CGSize(width: 45, height: 45))
            
            VStack(spacing: 2)
            {
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                let strYear = String(item.year)
                let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
                
                Text(item.year > 0 ? "\(strYear) • \(strCount)" : "\(strCount)")
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
    
    private func largeView() -> some View
    {
        VStack(spacing: 0)
        {
            ThumbView(url: item.thumb, albumId: item.albumId, size: CGSize(width: 150, height: 150))
            
            Text(item.title)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 10)
            
            let strYear = String(item.year)
            let strCount = item.count > 1 ? "\(String(item.count)) tracks" : "single"
            
            Text(item.year > 0 ? "\(strYear) • \(strCount)" : "\(strCount)")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 2)
        }
        .frame(width: 150)
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            clicked()
        }
    }
}
