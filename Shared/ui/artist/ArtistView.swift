//
//  ArtistView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.08.2022.
//

import SwiftUI

struct ArtistView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    var artistModel: ArtistModel
    var body: some View {
        VStack
        {
            Text(self.artistModel.name)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 20))
                .padding(30)
                .onlyLeading()
            
            Spacer()
        }
        .viewTitle(title: "Artist", back: true, leading: HStack {}, trailing: HStack {})
        .background(Color("color_background"))
    }
}
