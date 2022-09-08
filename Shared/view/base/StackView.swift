//
//  StackView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct StackView<Content: View, Trailing: View>: View
{
    var title: String
    var back: Bool
    
    @ViewBuilder let content: Content
    @ViewBuilder let menu: Trailing
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 15)
            {
                Button {
                    RootStack.shared.popToView()
                } label: {
                    Image("action_back")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                .removed(!back)

                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .removed(title.isEmpty)
                
                menu
            }
            .frame(height: 45)
            .padding(.horizontal, 15)
            .background(Color("color_toolbar").ignoresSafeArea(edges: .top))
            
            content
        }
        .background(Color("color_background").ignoresSafeArea(edges: .all))
    }
}
