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
            Text("MusApp")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 20))
                .padding(.top, 30)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Text("Music player using music from VK")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.top, 5)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Text("This is not a commercial project (a project for personal use)")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.top, 5)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Text("Thanks:")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 18))
                .padding(.top, 30)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Link("Social Network (VK)", destination: URL(string: "https://vk.com/")!)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Link("Resource with icons (svgrepo)", destination: URL(string: "https://www.svgrepo.com/")!)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
                .onlyLeading()
            
            Link("Author of icon packs (Shannon E. Thomas)", destination: URL(string: "https://dribbble.com/shannonethomas")!)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
                .onlyLeading()
            
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

            Text("Version: 1.0")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 12))
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .viewTitle(title: "About", back: true, leading: HStack {}, trailing: HStack {})
        .background(Color("color_background"))
    }
}
