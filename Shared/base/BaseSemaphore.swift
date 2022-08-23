//
//  BaseSemaphore.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

class BaseSemaphore
{
    static let shared = BaseSemaphore()
    
    let semaphore: DispatchSemaphore?

    init() {
        semaphore = DispatchSemaphore(value: 1)
    }
    
    func wait() {
        semaphore?.wait() // блокируем поток
    }
    
    func signal() {
        semaphore?.signal() // разблокируем поток
    }
}
