//
//  DBTasks.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

protocol ICVBaseTask {
    func execute() -> CLongLong
    func run()
}

class DBBaseTask: ICVBaseTask
{
    public var requestIdentifier: Int64
    static var dqueue: DispatchQueue = DispatchQueue(label: "appdbdispatchqueue")
    
    init() {
        self.requestIdentifier = Int64( Date().timeIntervalSince1970 * 1000 * 1000 * 1000 )
    }
    
    func execute() -> CLongLong {
        DBBaseTask.dqueue.async {
            self.run()
        }
        return self.requestIdentifier
    }
    
    func run() {

    }
}

class AllAudioTask: DBBaseTask
{
    private let delegate: IDBDelegate
    
    init(delegate: IDBDelegate) {
        self.delegate = delegate
    }
    
    override func run() {
        let list = SQLDataBase.shared.getAudioDao().getAllAudio()
        self.delegate.onAudioList(requestIdentifier: self.requestIdentifier, list: list)
    }
}

class AddAudioTask: DBBaseTask
{
    private var model: AudioModel
    private var delegate: IDBDelegate?
    
    init(model: AudioModel, delegate: IDBDelegate?) {
        self.model = model
        self.delegate = delegate
    }
    
    override func run() {
        self.model.timestamp = DBUtils.getTimestamp()
        if SQLDataBase.shared.getAudioDao().insertAudio(audio: self.model) {
            self.delegate?.onAudioAdded(requestIdentifier: self.requestIdentifier, model: self.model)
        } else {
            self.delegate?.onAudioAdded(requestIdentifier: self.requestIdentifier, model: nil)
        }
    }
}

class DeleteAudioTask: DBBaseTask
{
    private var audioId: String
    private var delegate: IDBDelegate?
    
    init(audioId: String, delegate: IDBDelegate?) {
        self.audioId = audioId
        self.delegate = delegate
    }
    
    override func run() {
        SQLDataBase.shared.getAudioDao().deleteAudioById(audioId: self.audioId)
        self.delegate?.onAudioDeleted(requestIdentifier: self.requestIdentifier, audioId: self.audioId)
    }
}
