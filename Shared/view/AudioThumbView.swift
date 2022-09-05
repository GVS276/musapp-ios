//
//  AudioThumbView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 10.08.2022.
//

import SwiftUI

struct AudioThumbView: View
{
    var big = false
    var body: some View
    {
        if big
        {
            Image("music")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 150, height: 150)
                .padding(75)
                .background(Color("color_thumb"))
                .cornerRadius(10)
        } else {
            Image("music")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .padding(10)
                .background(Color("color_thumb"))
                .clipShape(Circle())
        }
    }
}
