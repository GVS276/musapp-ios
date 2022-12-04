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
    
    init(url: String, albumId: String)
    {
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
                Image(uiImage: image.imageWith(newSize: CGSize(width: 45, height: 45)))
                    .clipShape(Circle())
            } else {
                Image("audio")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(Color("color_thumb"))
                    .clipShape(Circle())
            }
        }
    }
}
