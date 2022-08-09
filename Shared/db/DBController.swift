//
//  DBController.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

class DBController
{
    static var shared = DBController()
    
    func receiveAudioList(delegate: IDBDelegate) -> Int64
    {
        return AllAudioTask(delegate: delegate).execute()
    }
    
    func addAudio(model: AudioModel, delegate: IDBDelegate?) -> Int64
    {
        return AddAudioTask(model: model, delegate: delegate).execute()
    }
}
