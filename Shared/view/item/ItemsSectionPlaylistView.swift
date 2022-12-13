//
//  ItemsSectionPlaylistView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct ItemsSectionPlaylistView: View
{
    let block: SectionBlock
    let vertical: Bool
    let clicked: (_ playlist: AlbumModel) -> Void
    
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
        ForEach(block.playlists.indices, id: \.self) { index in
            
            let item = block.playlists[index]
            
            PlaylistItemView(item: item, large: false) {
                clicked(item)
            }
        }
    }
    
    private func horizontalList() -> some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            LazyHStack(spacing: 0)
            {
                ForEach(block.playlists.indices, id: \.self) { index in
                    
                    let item = block.playlists[index]
                    
                    PlaylistItemView(item: item, large: true) {
                        clicked(item)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
    }
}
