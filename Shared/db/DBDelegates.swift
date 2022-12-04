//
//  DBDelegates.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

enum DownloadStatus
{
    case Started
    case Finished
    case Failed
}

protocol IDBDelegate {
    /*
     * AUDIO
     */
    func onAudioList(requestIdentifier: Int64, list: Array<AudioModel>?)
    func onAudioAdded(requestIdentifier: Int64, model: AudioModel?)
    func onAudioDeleted(requestIdentifier: Int64, audioId: String)
    func onAudioFromDownloadDeleted(requestIdentifier: Int64, audioId: String)
    func onAudioDownload(requestIdentifier: Int64, audioId: String, status: DownloadStatus)
}

struct DBDelegate: Hashable
{
    let delegate: IDBDelegate
    var key: Int

    init(delegate: IDBDelegate, key: Int) {
        self.delegate = delegate
        self.key = key
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: DBDelegate, rhs: DBDelegate) -> Bool {
        let equal = (lhs.key == rhs.key)
        return equal
    }
}

class DBDelegateNotifier: BaseNotifier
{
    static let shared = DBDelegateNotifier()
    private var delegates = Set<DBDelegate>()
    
    func addDelegate(delegate: DBDelegate) {
        lock()
        
        delegates.insert(delegate)
        
        unlock()
    }

    func removeDelegate(delegate: DBDelegate) {
        lock()
        
        delegates.remove(delegate)
        
        unlock()
    }
    
    /*
     * MARK: AUDIO
     */
    
    func onAudioListResult(requestIdentifier: Int64, list: Array<AudioModel>?) {
        lock()

        for observer in delegates {
            observer.delegate.onAudioList(requestIdentifier: requestIdentifier, list: list)
        }
        
        unlock()
    }
    
    func onAudioAddedResult(requestIdentifier: Int64, model: AudioModel?) {
        lock()

        for observer in delegates {
            observer.delegate.onAudioAdded(requestIdentifier: requestIdentifier, model: model)
        }
        
        unlock()
    }
    
    func onAudioDeletedResult(requestIdentifier: Int64, audioId: String) {
        lock()

        for observer in delegates {
            observer.delegate.onAudioDeleted(requestIdentifier: requestIdentifier, audioId: audioId)
        }
        
        unlock()
    }
    
    func onAudioFromDownloadDeletedResult(requestIdentifier: Int64, audioId: String) {
        lock()

        for observer in delegates {
            observer.delegate.onAudioFromDownloadDeleted(requestIdentifier: requestIdentifier, audioId: audioId)
        }
        
        unlock()
    }
    
    func onAudioDownloadResult(requestIdentifier: Int64, audioId: String, status: DownloadStatus) {
        lock()

        for observer in delegates {
            observer.delegate.onAudioDownload(
                requestIdentifier: requestIdentifier, audioId: audioId, status: status)
        }
        
        unlock()
    }
}
