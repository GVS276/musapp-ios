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
    
    private let albumId: String
    private let size: CGSize
    
    init(url: String, albumId: String, size: CGSize)
    {
        self.albumId = albumId
        self.size = size
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
                Image(uiImage: image.imageWith(newSize: size))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image("audio")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: size.width, height: size.height)
                    .background(Color("color_thumb"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
