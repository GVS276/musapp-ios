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
        StackView(title: "About", back: true)
        {
            Text("MusApp")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 20))
                .padding(.top, 30)
                .padding(.horizontal, 30)
            
            Text("Music player using music from VK")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
            Text("This is not a commercial project (a project for personal use)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
            Text("Thanks:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 18))
                .padding(.top, 30)
                .padding(.horizontal, 30)
            
            Link("Social Network (VK)", destination: URL(string: "https://vk.com/")!)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
            Link("Resource with icons (svgrepo)", destination: URL(string: "https://www.svgrepo.com/")!)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
            Link("Author of icon packs (Shannon E. Thomas)", destination: URL(string: "https://dribbble.com/shannonethomas")!)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
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

            Text("Version: 1.01")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 12))
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        } menu: {
            EmptyView()
        }
    }
}
