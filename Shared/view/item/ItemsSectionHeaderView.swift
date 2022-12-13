//
//  ItemsSectionHeaderView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct ItemsSectionHeaderView: View
{
    let block: SectionBlock
    let clicked: (_ sectionId: String, _ title: String) -> Void
    
    var body: some View
    {
        HStack(spacing: 15)
        {
            Text(block.layout?.title ?? "Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
            
            if !block.buttons.isEmpty
            {
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            if let last = block.buttons.last
            {
                let id = last.sectionId ?? ""
                let text = block.layout?.title ?? "Title"
                
                clicked(id, text)
            }
        }
    }
}
