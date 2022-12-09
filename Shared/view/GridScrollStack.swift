//
//  GridScrollStack.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.12.2022.
//

import SwiftUI

struct GridScrollStack<Content: View>: View
{
    let rows: Int
    let count: Int
    let content: (Int) -> Content

    init(rows: Int, count: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.rows = rows
        self.count = count
        self.content = content
    }
    
    var body: some View
    {
        ScrollView(.horizontal, showsIndicators: false) {
            
            LazyVStack(spacing: 0)
            {
                ForEach(0 ..< rows, id: \.self) { row in
                    
                    LazyHStack(spacing: 0)
                    {
                        ForEach(0 ..< Int(ceil(Double(count / rows))), id: \.self) { col in
                            
                            content(row * Int(ceil(Double(count / rows))) + col)
                            
                        }
                    }
                    
                }
            }
            
        }
    }
}
