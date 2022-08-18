//
//  AboutView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 18.08.2022.
//

import SwiftUI

struct AboutView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Music player using music from VK\nThis is not a commercial project (a project for personal use)")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.vertical, 30)
                .padding(.bottom, 30)
            
            Spacer()
            
            Button {
                // TODO
            } label: {
                Text("Log out")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: 36)
            }
            .background(.blue)
            .cornerRadius(10)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)

            Text("Version: 1.0 - MusApp")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 12))
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .viewTitle(title: "About", back: true, leading: HStack {}, trailing: HStack {})
        .background(Color("color_background"))
    }
}
