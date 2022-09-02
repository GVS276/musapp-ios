//
//  AlbumModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 28.08.2022.
//

import Foundation

struct AlbumModel: Identifiable
{
    let id = UUID().uuidString
    var albumId: String = ""
    var title: String = ""
    var description: String = ""
    var thumb: String = ""
    var count: Int = 0
    var create_time: Int64 = 0
    var update_time: Int64 = 0
    var year: Int = 0
    var ownerId: Int = 0
    var accessKey: String = ""
    var isExplicit: Bool = false
}
