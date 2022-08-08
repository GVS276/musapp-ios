//
//  DBSemaphore.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

class DBSemaphore
{
    let semaphore: DispatchSemaphore?

    init() {
        semaphore = DispatchSemaphore(value: 1)
    }
    
    func wait() {}
    func signal() {}
}
