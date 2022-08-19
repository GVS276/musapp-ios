//
//  DBDelegates.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

protocol IDBDelegate {
    func onAudioList(requestIdentifier: Int64, list: Array<AudioModel>?)
    func onAudioAdded(requestIdentifier: Int64, model: AudioModel?)
    func onAudioDeleted(requestIdentifier: Int64, audioId: String)
}
