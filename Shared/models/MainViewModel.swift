//
//  MainViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.08.2022.
//

import Foundation

enum MainScene {
    case none
    case main
    case login
}

class MainViewModel: ObservableObject
{
    static let shared = MainViewModel()
    var onViewScene: ((_ scene: MainScene) -> Void)?
    
    private let DB = DBController.shared
    private var requestId: Int64? = nil
    private var receivedListCallback: ((_ list: [AudioStruct]) -> Void)!
    
    func showScene(scene: MainScene)
    {
        if let callback = self.onViewScene
        {
            callback(scene)
        }
    }
    
    func receiveAudioList(handler: @escaping ((_ list: [AudioStruct]) -> Void))
    {
        self.receivedListCallback = handler
        self.requestId = self.DB.receiveAudioList(delegate: self)
    }
}

extension MainViewModel: IDBDelegate
{
    func onAudioList(requestIdentifier: Int64, list: Array<AudioModel>?)
    {
        if self.requestId == requestIdentifier
        {
            var result = [AudioStruct]()
            if let list = list
            {
                list.forEach { model in
                    result.append(AudioStruct(model: model))
                }
            }
            
            DispatchQueue.main.async {
                if let callback = self.receivedListCallback
                {
                    callback(result)
                }
            }
        }
    }
}
