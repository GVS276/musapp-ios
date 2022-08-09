//
//  AudioPlayerModelView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct AudioStruct: Identifiable {
    let id = UUID().uuidString
    var model: AudioModel
    var isPlaying = false
}

enum PlayerMode: Int
{
    case FULL = 0,
         MINI
}

enum PlayerControl: Int
{
    case Next = 0,
         Previous,
         PlayOrPause
}

enum PlayingMode: Int
{
    case FromMain = 0,
         FromSearch
}

class AudioPlayerModelView: ObservableObject
{
    @Published var playedId: String = ""
    @Published var playerMode: PlayerMode = .MINI
    @Published var playedModel: AudioStruct? = nil
    
    @Published var audioPlaying = false
    @Published var audioPlayerReady = false
    
    @Published var audioList: [AudioStruct] = []
    @Published var searchList: [AudioStruct] = []
    
    private var playing = false
    private var playingMode: PlayingMode = .FromMain
    private var player: AVPlayer? = nil
    
    private var playerRateObserver: NSKeyValueObservation? = nil
    private var playerProgressObserver: Any? = nil
    private var playerFinishedObserver: Any? = nil
    
    private var playerReadyCallback: ((_ ready: Bool) -> Void)!
    private var playerPlayingCallback: ((_ playing: Bool, _ id: String) -> Void)!
    private var playerProgressCallback: ((_ current: Float, _ duration: Float) -> Void)!
    private var playerFinishedCallback: (() -> Void)!
    private var playerControlCallback: ((_ tag: PlayerControl) -> Void)!
    
    private let DB = DBController.shared
    private var requestReceiveId: Int64? = nil
    
    init()
    {
        self.receiveAudioList()
        self.addObserver { ready in
            self.audioPlayerReady = ready
        } finishedHandler: {
            print("finished")
            self.audioTrackFinished()
        } playingHandler: { playing, id in
            self.audioPlaying = playing
            self.setPlaying(id: id, value: playing)
        } controlHandler: { tag in
            if tag == .Next {
                self.audioTrackNext()
            }
            else if tag == .Previous {
                self.audioTrackPrevious()
            }
            else if tag == .PlayOrPause {
                self.playOrPause()
            }
        }
    }
    
    private func addObserver(readyHandler: @escaping ((_ ready: Bool) -> Void),
                             finishedHandler: @escaping (() -> Void),
                             playingHandler: @escaping ((_ playing: Bool, _ id: String) -> Void),
                             controlHandler: @escaping ((_ tag: PlayerControl) -> Void))
    {
        self.playerReadyCallback = readyHandler
        self.playerPlayingCallback = playingHandler
        self.playerFinishedCallback = finishedHandler
        self.playerControlCallback = controlHandler
    }
    
    func addProgress(progressHandler: @escaping ((_ current: Float, _ duration: Float) -> Void)) {
        self.playerProgressCallback = progressHandler
    }
    
    func setSearchList(list: [AudioStruct])
    {
        DispatchQueue.main.async {
            self.searchList.append(contentsOf: Array(list))
        }
    }
    
    func startStream(url: String, playedId: String, mode: PlayingMode)
    {
        // mode
        self.setPlayingMode(mode: mode)
        
        // stop player
        if self.player != nil
        {
            self.stop()
        }
        
        // new stream
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            
            guard let url = URL.init(string: url) else {
                return
            }
            
            let playerItem = AVPlayerItem.init(url: url)
            self.player = AVPlayer.init(playerItem: playerItem)
            self.player?.play()
            
            self.playing = true
            self.playedId = playedId
            self.playerObservers()
            
            if let callback = self.playerPlayingCallback {
                callback(self.playing, self.playedId)
            }
            
            self.ready(value: true)
        } catch {
            self.ready(value: false)
        }
    }
    
    private func playerObservers()
    {
        if let player = self.player
        {
            self.playerRateObserver = player.observe(\.rate, options:  [.new, .old], changeHandler: { (player, change) in
                self.playing = player.rate == 1
                if let callback = self.playerPlayingCallback {
                    callback(self.playing, self.playedId)
                }
            })
            
            self.playerProgressObserver = player.addProgressObserver { current, duration in
                if let callback = self.playerProgressCallback
                {
                    callback(current, duration)
                }
                self.nowPlayingInfo(current: Double(current), duration: Double(duration))
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    @objc
    private func playerDidFinishPlaying(note: NSNotification){
        if let callback = self.playerFinishedCallback
        {
            callback()
        }
    }
    
    func control(tag: PlayerControl)
    {
        if let callback = self.playerControlCallback {
            callback(tag)
        }
    }
    
    func play()
    {
        self.player?.play()
    }
    
    func pause()
    {
        self.player?.pause()
    }
    
    func stop()
    {
        self.playerRateObserver = nil
        self.playerProgressObserver = nil
        self.playerFinishedObserver = nil
        
        self.player?.pause()
        self.player?.seek(to: .zero)
        self.player = nil
        
        self.playedId = ""
        self.ready(value: false)
    }
    
    private func ready(value: Bool)
    {
        if let callback = self.playerReadyCallback {
            callback(value)
        }
    }
    
    /*
     * MP Center
     */
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { event in
            self.pause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { event in
            self.control(tag: .Next)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { event in
            self.control(tag: .Previous)
            return .success
        }
    }
    
    private func nowPlayingInfo(current: Double, duration: Double) {
        var info = [String : Any]()
        info[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = current
        info[MPMediaItemPropertyTitle] = self.playedModel?.model.title ?? ""
        info[MPMediaItemPropertyArtist] = self.playedModel?.model.artist ?? ""
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /*
     * for control UI
     */
    private func playOrPause()
    {
        if self.audioPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    private func oldTrackStopped()
    {
        if self.playedId.isEmpty
        {
            return
        }
        
        if self.playingMode == .FromMain
        {
            if let index =  self.audioList.firstIndex(where: {$0.id == self.playedId})
            {
                self.audioList[index].isPlaying = false
            }
        } else {
            if let index =  self.searchList.firstIndex(where: {$0.id == self.playedId})
            {
                self.searchList[index].isPlaying = false
            }
        }
    }
    
    private func setPlaying(id: String, value: Bool)
    {
        if self.playingMode == .FromMain
        {
            if let index = self.audioList.firstIndex(where: {$0.id == id})
            {
                self.audioList[index].isPlaying = value
                self.playedModel = self.audioList[index]
            }
        } else {
            if let index = self.searchList.firstIndex(where: {$0.id == id})
            {
                self.searchList[index].isPlaying = value
                self.playedModel = self.searchList[index]
            }
        }
    }
    
    private func setPlayingMode(mode: PlayingMode)
    {
        self.oldTrackStopped()
        
        if mode == .FromMain, !self.searchList.isEmpty
        {
            self.searchList.removeAll()
        }
        
        self.playingMode = mode
    }
    
    private func audioTrackFinished()
    {
        if self.playingMode == .FromMain
        {
            if let index = self.audioList.firstIndex(where: {$0.id == self.playedId}) {
                let next = index + 1
                if next > self.audioList.count - 1
                {
                    self.oldTrackStopped()
                    self.stop()
                } else {
                    let audio = self.audioList[next]
                    self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
                }
            }
        } else {
            if let index = self.searchList.firstIndex(where: {$0.id == self.playedId}) {
                let next = index + 1
                if next > self.searchList.count - 1
                {
                    self.oldTrackStopped()
                    self.stop()
                } else {
                    let audio = self.searchList[next]
                    self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
                }
            }
        }
    }
    
    private func audioTrackNext()
    {
        if self.playingMode == .FromMain
        {
            if let index = self.audioList.firstIndex(where: {$0.id == self.playedId}) {
                let next = index + 1 > self.audioList.count - 1 ? 0 : index + 1
                let audio = self.audioList[next]
                self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
            }
        } else {
            if let index = self.searchList.firstIndex(where: {$0.id == self.playedId}) {
                let next = index + 1 > self.searchList.count - 1 ? 0 : index + 1
                let audio = self.searchList[next]
                self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
            }
        }
    }
    
    private func audioTrackPrevious()
    {
        if self.playingMode == .FromMain
        {
            if let index = self.audioList.firstIndex(where: {$0.id == self.playedId}) {
                let previous = index - 1 < 0 ? self.audioList.count - 1 : index - 1
                let audio = self.audioList[previous]
                self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
            }
        } else {
            if let index = self.searchList.firstIndex(where: {$0.id == self.playedId}) {
                let previous = index - 1 < 0 ? self.searchList.count - 1 : index - 1
                let audio = self.searchList[previous]
                self.startStream(url: audio.model.streamUrl, playedId: audio.id, mode: self.playingMode)
            }
        }
    }
    
    /*
     * DB
     */
    
    func receiveAudioList()
    {
        self.requestReceiveId = self.DB.receiveAudioList(delegate: self)
    }
    
    func addAudioToDB(model: AudioStruct)
    {
        var newModel = model
        newModel.isPlaying = false
        
        self.audioList.insert(newModel, at: 0)
        self.DB.addAudio(model: newModel.model)
        
        Toast.shared.show(text: "Added to your data base")
    }
}

extension AudioPlayerModelView: IDBDelegate
{
    func onAudioList(requestIdentifier: Int64, list: Array<AudioModel>?)
    {
        if self.requestReceiveId == requestIdentifier
        {
            var result = [AudioStruct]()
            if let list = list
            {
                list.forEach { model in
                    result.append(AudioStruct(model: model))
                }
            }
            
            DispatchQueue.main.async {
                self.audioList = result
            }
        }
    }
}
