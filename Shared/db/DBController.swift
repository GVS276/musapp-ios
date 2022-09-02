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
    
    func deleteAudio(audioId: String, delegate: IDBDelegate?) -> Int64
    {
        return DeleteAudioTask(audioId: audioId, delegate: delegate).execute()
    }
    
    func deleteAudioFromDownload(audioId: String, delegate: IDBDelegate?) -> Int64
    {
        return DeleteAudioFromDownloadTask(audioId: audioId, delegate: delegate).execute()
    }
    
    /*
     * Not main thread
     */
    func setDownloaded(audioId: String, value: Bool)
    {
        BaseSemaphore.shared.wait()
        
        SQLDataBase.shared.getAudioDao().setDownloaded(audioId: audioId, value: value)
        
        BaseSemaphore.shared.signal()
    }
}
