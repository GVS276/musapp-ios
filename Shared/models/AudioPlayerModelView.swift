//
//  AudioPlayerModelView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import AVFoundation
import MediaPlayer

struct AudioStruct: Identifiable {
    let id = UUID().uuidString
    let model: AudioModel
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
         Previous
}

class AudioPlayerModelView: ObservableObject
{
    @Published var playedId: String = ""
    @Published var playerMode: PlayerMode = .MINI
    @Published var playedModel: AudioStruct? = nil
    
    private var playing = false
    private var player: AVPlayer? = nil
    
    private var playerRateObserver: NSKeyValueObservation? = nil
    private var playerProgressObserver: Any? = nil
    private var playerFinishedObserver: Any? = nil
    
    private var playerReadyCallback: ((_ ready: Bool) -> Void)!
    private var playerPlayingCallback: ((_ playing: Bool, _ id: String) -> Void)!
    private var playerProgressCallback: ((_ current: Float, _ duration: Float) -> Void)!
    private var playerFinishedCallback: (() -> Void)!
    private var playerControlCallback: ((_ tag: PlayerControl) -> Void)!
    
    func addObserver(readyHandler: @escaping ((_ ready: Bool) -> Void),
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
    
    func startStream(url: String, playedId: String)
    {
        if self.player != nil
        {
            self.stop()
        }
        
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
}
