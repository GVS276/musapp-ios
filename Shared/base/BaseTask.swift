//
//  BaseTask.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 22.08.2022.
//

import Foundation

protocol IBaseTask {
    func execute() -> CLongLong
    func run()
}

class BaseTask: IBaseTask
{
    public var requestIdentifier: Int64
    static var dqueue: DispatchQueue = DispatchQueue(label: "appdbdispatchqueue")
    
    init() {
        self.requestIdentifier = Int64( Date().timeIntervalSince1970 * 1000 * 1000 * 1000 )
    }
    
    func execute() -> CLongLong {
        BaseTask.dqueue.async {
            self.run()
        }
        return self.requestIdentifier
    }
    
    func run() {

    }
}
