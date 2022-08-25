//
//  ProfileHeaderView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 25.08.2022.
//

import SwiftUI

struct ProfileHeaderView<Header: View, Content: View>: View
{
    @Environment(\.presentationMode) private var presentationMode
    @State private var showToolbar = false
    
    private let headerHeight: CGFloat = 350
    private let toolbarHeight: CGFloat = 45
    
    let title: String
    @ViewBuilder let header: Header
    @ViewBuilder let content: Content
    
    var body: some View
    {
        ZStack(alignment: .top)
        {
            ScrollView(.vertical, showsIndicators: false)
            {
                VStack(spacing: 0)
                {
                    GeometryReader { geometry -> AnyView in
                        let end: CGFloat = self.headerHeight - (self.toolbarHeight * 2)
                        let minY =  geometry.frame(in: .global).minY
                        let per = min(1, abs(abs(min(0, minY)) / end))
                        let stretch = minY > 0 ? self.headerHeight + abs(minY / 9) : self.headerHeight
                        let y = minY + end
                        
                        DispatchQueue.main.async {
                            if y < 0
                            {
                                showToolbar = true
                            } else {
                                showToolbar = false
                            }
                        }
                        
                        return AnyView(
                            ZStack(alignment: .bottom)
                            {
                                ZStack
                                {
                                    header
                                }
                                .frame(width: geometry.size.width, height: stretch)
                                .opacity(1.0 - per)
                                
                                Text(title)
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                                    .lineLimit(1)
                                    .shadow(color: .white, radius: 20, x: 0, y: 0)
                                    .padding(.vertical, 30)
                                    .padding(.horizontal, 15)
                                    .opacity(1.0 - per)
                            }
                            .frame(height: stretch)
                            .background(Color("color_toolbar"))
                            .offset(y: -minY)
                        )
                    }
                    .frame(height: self.headerHeight)
                    
                    content
                }
            }
            .ignoresSafeArea(edges: .top)
            
            HStack(spacing: 0)
            {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("action_back")
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                }
                .padding(.horizontal, 15)
                
                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 15)
                    .removed(!self.showToolbar)
                
                Spacer()
            }
            .frame(height: self.toolbarHeight)
            .background(self.showToolbar ? Color("color_toolbar").ignoresSafeArea(edges: .top) : Color.clear.ignoresSafeArea(edges: .top))
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color("color_background"))
    }
}