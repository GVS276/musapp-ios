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
    @State private var opacity: CGFloat = .zero
    
    private let headerHeight: CGFloat = 350
    private let toolbarHeight: CGFloat = 45
    
    let title: String
    let subTitle: String
    
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
                        let stretch = minY > 0 ? self.headerHeight + abs(minY / 9) : self.headerHeight
                        
                        DispatchQueue.main.async {
                            self.opacity = min(1, abs(abs(min(0, minY)) / end))
                        }
                        
                        return AnyView(
                            ZStack(alignment: .bottom)
                            {
                                ZStack
                                {
                                    header
                                }
                                .frame(width: geometry.size.width, height: stretch)
                                
                                VStack
                                {
                                    Text(self.title)
                                        .foregroundColor(Color("color_text"))
                                        .font(.system(size: 18))
                                        .lineLimit(1)
                                    
                                    Text(self.subTitle)
                                        .foregroundColor(Color("color_text"))
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                        .removed(self.subTitle.isEmpty)
                                }
                                .padding(.vertical, 30)
                                .padding(.horizontal, 15)
                            }
                            .frame(height: stretch)
                            .background(Color("color_toolbar"))
                            .offset(y: -minY)
                            .opacity(1.0 - self.opacity)
                        )
                    }
                    .frame(height: self.headerHeight)
                    
                    content
                        .frame(minHeight: self.headerHeight)
                        .background(Color("color_background"))
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
                    .opacity(self.opacity)
                
                Spacer()
            }
            .frame(height: self.toolbarHeight)
            .background(Color("color_toolbar").ignoresSafeArea(edges: .top).opacity(self.opacity))
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color("color_background"))
    }
}
