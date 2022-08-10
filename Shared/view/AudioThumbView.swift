//
//  AudioThumbView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.08.2022.
//

import SwiftUI

struct AudioThumbView: View
{
    var color: Color = Color("color_thumb")
    var body: some View
    {
        Image("music")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 25, height: 25)
            .padding(10)
            .background(color)
            .clipShape(Circle())
    }
}
