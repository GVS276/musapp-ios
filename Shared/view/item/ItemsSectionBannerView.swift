//
//  ItemsSectionBannerView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct ItemsSectionBannerView: View
{
    let block: SectionBlock
    let clicked: (_ playlistId: String, _ ownerId: String, _ accessKey: String) -> Void
    
    var body: some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(block.banners, id: \.id) { item in
                    createBanner(item: item)
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    private func createBanner(item: CatalogBanner) -> some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            ThumbView(url: item.image ?? "",
                      id: String(item.id ?? 0),
                      type: .Banner,
                      size: CGSize(width: 300, height: 150))
            
            Text(item.title ?? "Title")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(2)
                .padding(.top, 10)
            
            Text(item.text ?? "Text")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(2)
                .padding(.top, 2)
            
            Text(item.subtext ?? "Subtext")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(2)
                .padding(.top, 2)
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300,
               minHeight: 150, idealHeight: nil, maxHeight: 300,
               alignment: .topLeading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .onTapGesture {
            
            if let url = item.url {
                
                if let last = url.split(separator: "/").last {
                    
                    let inf = last.split(separator: "_")
                    
                    guard inf.count == 3 else {
                        return
                    }
                    
                    let ownerId = String(inf[0])
                    let playlistId = String(inf[1])
                    let accessKey = String(inf[2])
                    
                    clicked(playlistId, ownerId, accessKey)
                }
            }
        }
    }
}
