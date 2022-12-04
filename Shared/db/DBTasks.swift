//
//  DBTasks.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation
import mobileffmpeg

/*
 * MARK: AUDIO
 */

class AllAudioTask: BaseTask
{
    override func run() {
        let list = SQLDataBase.shared.getAudioDao().getAllAudio()
        DBDelegateNotifier.shared.onAudioListResult(requestIdentifier: self.requestIdentifier, list: list)
    }
}

class AddAudioTask: BaseTask
{
    private var model: AudioModel
    
    init(model: AudioModel) {
        self.model = model
    }
    
    override func run() {
        self.model.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        if SQLDataBase.shared.getAudioDao().insertAudio(audio: self.model) {
            DBDelegateNotifier.shared.onAudioAddedResult(
                requestIdentifier: self.requestIdentifier, model: self.model)
        } else {
            DBDelegateNotifier.shared.onAudioAddedResult(
                requestIdentifier: self.requestIdentifier, model: nil)
        }
    }
}

class DeleteAudioTask: BaseTask
{
    private var audioId: String
    
    init(audioId: String) {
        self.audioId = audioId
    }
    
    override func run() {
        self.deleteFromDisk()
        
        DBDelegateNotifier.shared.onAudioDeletedResult(
            requestIdentifier: self.requestIdentifier, audioId: self.audioId)
    }
    
    private func deleteFromDisk()
    {
        if let audioUrl = UIFileUtils.getAnyFileUri(path: AUDIO_PATH, fileName: "\(self.audioId).mp3") {
            if UIFileUtils.existFile(fileUrl: audioUrl)
            {
                UIFileUtils.removeFile(fileUrl: audioUrl)
            }
        }
        
        SQLDataBase.shared.getAudioDao().deleteAudioById(audioId: self.audioId)
    }
}

class DeleteAudioFromDownloadTask: BaseTask
{
    private var audioId: String
    
    init(audioId: String) {
        self.audioId = audioId
    }
    
    override func run() {
        self.deleteFromDisk()
        
        DBDelegateNotifier.shared.onAudioFromDownloadDeletedResult(
            requestIdentifier: self.requestIdentifier, audioId: self.audioId)
    }
    
    private func deleteFromDisk()
    {
        if let audioUrl = UIFileUtils.getAnyFileUri(path: AUDIO_PATH, fileName: "\(self.audioId).mp3") {
            if UIFileUtils.existFile(fileUrl: audioUrl)
            {
                UIFileUtils.removeFile(fileUrl: audioUrl)
                SQLDataBase.shared.getAudioDao().setDownloaded(audioId: self.audioId, value: false)
            }
        }
    }
}

class DownloadAudioTask: BaseTask
{
    private var model: AudioModel
    
    init(model: AudioModel)
    {
        self.model = model
    }
    
    override func run()
    {
        var executeId: Int32 = 0
        
        DBDelegateNotifier.shared.onAudioDownloadResult(
            requestIdentifier: self.requestIdentifier, audioId: model.audioId, status: .Started)
        
        if let output = UIFileUtils.getAnyFileUri(path: AUDIO_PATH, fileName: "\(model.audioId).mp3")
        {
            if UIFileUtils.existFile(fileUrl: output)
            {
                UIFileUtils.removeFile(fileUrl: output)
            }
            
            executeId = MobileFFmpeg.execute("-http_persistent false -i \(model.streamUrl) \(output.path)")
        }
        
        if executeId == RETURN_CODE_SUCCESS
        {
            SQLDataBase.shared.getAudioDao().setDownloaded(audioId: model.audioId, value: true)
            
            DBDelegateNotifier.shared.onAudioDownloadResult(
                requestIdentifier: self.requestIdentifier, audioId: model.audioId, status: .Finished)
        } else {
            DBDelegateNotifier.shared.onAudioDownloadResult(
                requestIdentifier: self.requestIdentifier, audioId: model.audioId, status: .Failed)
        }
    }
}
