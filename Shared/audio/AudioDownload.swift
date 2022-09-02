//
//  AudioDownload.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 28.08.2022.
//

import mobileffmpeg

enum AudioDownloadStatus
{
    case Started
    case Finished
    case Failed
}

protocol DownloadDelegate {
    func onDownload(requestIdentifier: Int64, audioId: String, status: AudioDownloadStatus)
}

class AudioDownload: BaseTask
{
    var urlString: String
    var audioId: String
    var delegate: DownloadDelegate
    
    init(urlString: String, audioId: String, delegate: DownloadDelegate)
    {
        self.urlString = urlString
        self.audioId = audioId
        self.delegate = delegate
    }
    
    override func run()
    {
        var executeId: Int32 = 0
        
        self.delegate.onDownload(requestIdentifier: self.requestIdentifier,
                                 audioId: self.audioId, status: .Started)
        
        BaseSemaphore.shared.wait()
        
        if let output = UIFileUtils.getAnyFileUri(path: AUDIO_PATH, fileName: "\(self.audioId).mp3")
        {
            if UIFileUtils.existFile(fileUrl: output)
            {
                UIFileUtils.removeFile(fileUrl: output)
            }
            
            executeId = MobileFFmpeg.execute("-http_persistent false -i \(self.urlString) \(output.path)")
        }
        
        BaseSemaphore.shared.signal()
        
        self.delegate.onDownload(requestIdentifier: self.requestIdentifier,
                                 audioId: self.audioId,
                                 status: executeId == RETURN_CODE_SUCCESS ? .Finished : .Failed)
    }
}
