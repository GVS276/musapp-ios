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
    
    func addDelegate(delegate: DBDelegate)
    {
        DBDelegateNotifier.shared.addDelegate(delegate: delegate)
    }

    func removeDelegate(delegate: DBDelegate)
    {
        DBDelegateNotifier.shared.removeDelegate(delegate: delegate)
    }
    
    /*
     * MARK: AUDIO
     */
    
    func receiveAudioList() -> Int64
    {
        return AllAudioTask().execute()
    }
    
    func addAudio(model: AudioModel) -> Int64
    {
        return AddAudioTask(model: model).execute()
    }
    
    func deleteAudio(audioId: String) -> Int64
    {
        return DeleteAudioTask(audioId: audioId).execute()
    }
    
    func deleteAudioFromDownload(audioId: String) -> Int64
    {
        return DeleteAudioFromDownloadTask(audioId: audioId).execute()
    }
    
    func downloadAudio(model: AudioModel) -> Int64
    {
        return DownloadAudioTask(model: model).execute()
    }
}
