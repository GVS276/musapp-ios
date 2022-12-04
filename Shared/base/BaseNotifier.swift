//
//  BaseNotifier.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 03.10.2022.
//

import Foundation

class BaseNotifier {
    let semaphore: DispatchSemaphore
    
    init() {
        semaphore = DispatchSemaphore(value: 1)
    }
    
    func lock() {
        semaphore.wait()
    }
    
    func unlock() {
        semaphore.signal()
    }
}
