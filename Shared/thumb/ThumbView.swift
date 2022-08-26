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
        Group {
            if let image = self.model.cache[self.albumId] {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .removed(self.big)
                
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
                    .removed(!self.big)
            } else {
                AudioThumbView(big: self.big)
            }
        }
    }
}
