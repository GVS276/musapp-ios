//
//  ThumbView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 21.08.2022.
//

import SwiftUI

enum ThumbType {
    case Track
    case Playlist
    case Player
    case Banner
    case Link
}

struct ThumbView: View
{
    @StateObject private var model: ThumbModel
    
    private let id: String
    private let type: ThumbType
    private let size: CGSize
    
    init(url: String, id: String, type: ThumbType, size: CGSize)
    {
        self.id = id
        self.type = type
        self.size = size
        self._model = StateObject(wrappedValue: ThumbModel(thumbUrl: url, thumbAlbumId: id))
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
            if let image = self.model.cache[id]
            {
                
                switch type {
                case .Track, .Player, .Playlist, .Banner:
                    Image(uiImage: image.imageWith(newSize: size))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                case .Link:
                    Image(uiImage: image.imageWith(newSize: size))
                        .clipShape(Circle())
                }
                
            } else {
                switch type {
                    
                case .Track:
                    Image("audio")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: size.width, height: size.height)
                        .background(Color("color_thumb"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                case.Playlist:
                    Image("album")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: size.width, height: size.height)
                        .background(Color("color_thumb"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                case .Player:
                    Image("audio")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: size.width, height: size.height)
                        .background(Color("color_thumb_dark"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                case .Banner:
                    Color.gray
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                case .Link:
                    Image("action_my")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: size.width, height: size.height)
                        .background(Color("color_thumb"))
                        .clipShape(Circle())
                }
            }
        }
    }
}
