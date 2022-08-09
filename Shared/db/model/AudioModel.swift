//
//  AudioModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

struct AudioModel
{
    var audioId: String = ""
    var artist: String = ""
    var title: String = ""
    var streamUrl: String = ""
    var downloadUrl: String = ""
    var duration: Int32 = 0
    var isDownloaded: Int32 = 0
    var timestamp: Int64 = 0
}
