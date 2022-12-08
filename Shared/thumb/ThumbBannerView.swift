//
//  ThumbBannerView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import SwiftUI

struct ThumbBannerView: View
{
    @StateObject private var model: ThumbModel
    
    private let bannerId: String
    
    init(url: String, bannerId: String)
    {
        self.bannerId = bannerId
        self._model = StateObject(wrappedValue: ThumbModel(thumbUrl: url, thumbAlbumId: bannerId))
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
            if let image = self.model.cache[self.bannerId]
            {
                Image(uiImage: image.imageWith(newSize: CGSize(width: 300, height: 150)))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Color.gray
                    .frame(width: 300, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
