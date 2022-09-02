//
//  AudioStruct.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 28.08.2022.
//

import Foundation

struct AudioStruct: Identifiable, Equatable
{
    let id = UUID().uuidString
    var model: AudioModel
    
    var isPlaying = false
    
    static func == (lhs: AudioStruct, rhs: AudioStruct) -> Bool {
        return lhs.id == rhs.id
    }
}
