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
    
    init(model: AudioModel) {
        self.model = model
    }
    
    override func run() {
        self.model.timestamp = DBUtils.getTimestamp()
        SQLDataBase.shared.getAudioDao().insertAudio(audio: self.model)
    }
}
