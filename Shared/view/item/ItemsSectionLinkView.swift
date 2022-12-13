//
//  ItemsSectionLinkView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct ItemsSectionLinkView: View
{
    let block: SectionBlock
    let vertical: Bool
    let clicked: (_ artistDomain: String) -> Void
    
    var body: some View
    {
        if vertical
        {
            verticalList()
        } else {
            horizontalList()
        }
    }
    
    private func verticalList() -> some View
    {
        ForEach(block.links, id: \.id) { item in
            createLinkVertical(item: item)
        }
    }
    
    private func createLinkVertical(item: CatalogLink) -> some View
    {
        HStack(spacing: 15)
        {
            ThumbView(url: item.image ?? "",
                      id: item.id ?? "",
                      type: .Link,
                      size: CGSize(width: 45, height: 45))
            
            VStack(spacing: 2)
            {
                Text(item.title ?? "Title")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                Text(item.subtitle ?? "SubTitle")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .removed(item.subtitle?.isEmpty ?? true)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            
        }
    }
    
    private func horizontalList() -> some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(block.links, id: \.id) { item in
                    createLinkHorizontal(item: item)
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    private func createLinkHorizontal(item: CatalogLink) -> some View
    {
        VStack(spacing: 0)
        {
            ThumbView(url: item.image ?? "",
                      id: item.id ?? "",
                      type: .Link,
                      size: CGSize(width: 80, height: 80))
            
            Text(item.title ?? "Title")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 10)
            
            Text(item.subtitle ?? "SubTitle")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 2)
                .removed(item.subtitle?.isEmpty ?? true)
        }
        .frame(width: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            guard let meta = item.meta, meta.contentType == "artist" else {
                return
            }
            
            guard let url = item.url, let last = url.split(separator: "/").last else {
                return
            }
            
            clicked(String(last))
        }
    }
}
