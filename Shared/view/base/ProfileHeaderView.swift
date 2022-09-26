//
//  ProfileHeaderView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 25.08.2022.
//

import SwiftUI

struct ProfileHeaderView<Header: View, Content: View>: View
{
    @State private var opacity: CGFloat = .zero
    
    private let headerHeight: CGFloat = 350
    private let toolbarHeight: CGFloat = 45
    
    let title: String
    let subTitle: String
    
    @ViewBuilder let header: Header
    @ViewBuilder let content: Content
    
    var body: some View
    {
        GeometryReader { proxy in // проверим размеры родительского вию
            
            ZStack(alignment: .top) // родитель
            {
                ScrollView(.vertical, showsIndicators: false) // общий скроллинг
                {
                    VStack(spacing: 0) // вертикальный контейнер
                    {
                        // геометральный хидер чтобы отслеживать позицию в скроллинге
                        // результат будет правильный и фиксированный хидер (вью)
                        headerBody
                        
                        // контент виде списка
                        content
                            .frame(minHeight: proxy.size.height - toolbarHeight, alignment: .top)
                            .background(Color("color_background"))
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // тулбар будет выше всех
                toolbarBody
            }
            .background(Color("color_background").ignoresSafeArea(edges: .all))
            
        }
    }
    
    private var toolbarBody: some View
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
            
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .opacity(opacity)
        }
        .frame(height: self.toolbarHeight)
        .padding(.horizontal, 15)
        .background(Color("color_toolbar").ignoresSafeArea(edges: .top))
    }
    
    private var headerBody: some View
    {
        GeometryReader { geometry -> AnyView in
            
            // вычислим начало тулбара
            let end: CGFloat = self.headerHeight - (self.toolbarHeight * 2)
            
            // минимальный Y позиция в скроллинге
            let minY =  geometry.frame(in: .global).minY
            
            // будем растягивать хидер
            let stretch = minY > 0 ? self.headerHeight + abs(minY / 9) : self.headerHeight
            
            // прозрачность для тулбара (да, вывод будет в main поток,
            // т.к. все вычисление проходят не в главном потоке)
            DispatchQueue.main.async {
                self.opacity = min(1, abs(abs(min(0, minY)) / end))
            }
            
            // построим наш хидер (вью) и выведем
            return AnyView(
                VStack(spacing: 0)
                {
                    header
                        .padding(.top, self.toolbarHeight)
                        .padding(.bottom, 15)
                        .opacity(1.0 - self.opacity)

                    Text(self.title)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 18))
                        .padding(.bottom, 5)
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    
                    Text(self.subTitle)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                        .removed(self.subTitle.isEmpty)
                }
                .frame(width: geometry.size.width, height: stretch, alignment: .center)
                .background(Color("color_toolbar"))
                .offset(y: -minY)
            )
        }
        .frame(height: self.headerHeight)
    }
}
