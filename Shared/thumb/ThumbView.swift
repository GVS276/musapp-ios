//
//  ThumbView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.08.2022.
//

import SwiftUI

struct ThumbView: View
{
    @StateObject private var model: ThumbModel
    
    private var big: Bool
    private var albumId: String
    
    init(url: String, albumId: String, big: Bool)
    {
        self.big = big
        self.albumId = albumId
        self._model = StateObject(wrappedValue: ThumbModel(thumbUrl: url, thumbAlbumId: albumId))
    }
    
    var body: some View
    {
        self.thumb
            .onAppear {
                self.model.receiveThumb()
            }
    }
    
    private var thumb: some View
    {
        ZStack
        {
            if let image = self.model.cache[self.albumId]
            {
                if big
                {
                    Image(uiImage: image.imageWith(newSize: CGSize(width: 300, height: 300)))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(uiImage: image.imageWith(newSize: CGSize(width: 45, height: 45)))
                        .clipShape(Circle())
                }
            } else {
                if big {
                    Image("music")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 300)
                        .background(Color("color_thumb"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image("music")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 45, height: 45)
                        .background(Color("color_thumb"))
                        .clipShape(Circle())
                }
            }
        }
    }
}
