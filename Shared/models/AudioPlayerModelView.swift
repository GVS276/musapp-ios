//
//  AudioPlayerModelView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import AVFoundation
import MediaPlayer
import SwiftUI

struct AudioStruct: Identifiable, Equatable
{
    let id = UUID().uuidString
    let model: AudioModel
    
    var isPlaying = false
    
    static func == (lhs: AudioStruct, rhs: AudioStruct) -> Bool {
        return lhs.id == rhs.id
    }
}

enum PlayerControl: Int
{
    case Next = 0,
         Previous,
         PlayOrPause
}

class AudioPlayerModelView: ObservableObject
{
    @Published var playerSheet: Bool = false
    @Published var playedModel: AudioStruct? = nil
    
    @Published var audioPlaying = false
    @Published var audioPlayerReady = false
    
    @Published var audioList: [AudioStruct] = []
    
    private var player: AVPlayer? = nil
    private var playerCurrentTime: ((_ current: Float) -> Void)? = nil
    private var playerList: [AudioStruct] = []
    
    private var playerRateObserver: NSKeyValueObservation? = nil
    private var playerProgressObserver: Any? = nil
    
    private let DB = DBController.shared
    private var requestReceiveId: Int64? = nil
    private var requestAddId: Int64? = nil
    private var requestDeleteId: Int64? = nil
    
    init() {
        self.receiveAudioList()
    }
    
    func setPlayerList(list: [AudioStruct])
    {
        if !self.playerList.elementsEqual(list) {
            self.playerList.removeAll()
            self.playerList.append(contentsOf: list)
        }
    }
    
    func startStream(model: AudioStruct)
    {
        // destroy player
        if self.player != nil
        {
            self.destroy()
        }
        
        // new stream
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            
            guard let url = URL.init(string: model.model.streamUrl) else {
                return
            }
            
            // player init
            let playerItem = AVPlayerItem.init(url: url)
            self.player = AVPlayer.init(playerItem: playerItem)
            self.playedModel = model
            self.playerObservers()
            self.player?.play()
            
            // info (about track)
            self.nowPlayingInfo(current: 0)
            
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
                self.audioPlaying = player.rate == 1
                self.playedModel?.isPlaying = self.audioPlaying
            })
            
            self.playerProgressObserver = player.addProgressObserver { current, duration in
                if let handler = self.playerCurrentTime
                {
                    handler(current)
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    @objc
    private func playerDidFinishPlaying(note: NSNotification) {
        self.audioTrackFinished()
    }
    
    private func ready(value: Bool)
    {
        self.audioPlayerReady = value
    }
    
    private func destroy()
    {
        self.playerRateObserver = nil
        self.playerProgressObserver = nil
        
        self.player?.pause()
        self.player?.seek(to: .zero)
        self.player = nil

        self.playedModel = nil
    }
    
    func control(tag: PlayerControl)
    {
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
        self.destroy()
        self.ready(value: false)
    }
    
    func currentTime() -> Float
    {
        if let currentTime = self.player?.currentTime()
        {
            return Float(CMTimeGetSeconds(currentTime))
        }
        return .zero
    }
    
    func initCurrentTime(handler: @escaping (_ current: Float) -> Void)
    {
        self.playerCurrentTime = handler
    }
    
    func removeCurrentTime()
    {
        self.playerCurrentTime = nil
    }
    
    func seek(value: Float)
    {
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 60000)
        self.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        self.nowPlayingInfo(current: value)
    }
    
    func seek(time: TimeInterval)
    {
        let timeMaked = CMTimeMakeWithSeconds(time, preferredTimescale: 60000)
        self.player?.seek(to: timeMaked, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func repeatAudio(value: Bool)
    {
        UserDefaults.standard.set(value, forKey: "repeat")
        UserDefaults.standard.synchronize()
    }
    
    func randomAudio(value: Bool)
    {
        UserDefaults.standard.set(value, forKey: "random")
        UserDefaults.standard.synchronize()
    }
    
    func isRepeatAudio() -> Bool
    {
        return UserDefaults.standard.object(forKey: "repeat") as? Bool ?? false
    }
    
    func isRandomAudio() -> Bool
    {
        return UserDefaults.standard.object(forKey: "random") as? Bool ?? false
    }
    
    /*
     * MP Center
     */
    
    func setupCommandCenter()
    {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { event in
            self.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { event in
            self.control(tag: .Next)
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { event in
            self.control(tag: .Previous)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(time: event.positionTime)
            }
            return .success
        }
    }
    
    private func nowPlayingInfo(current: Float) {
        var info = [String : Any]()
        if let img = ThumbCacheObj.cache[self.playedModel?.model.albumId ?? ""]
        {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { size in
                return img.imageWith(newSize: size)
            }
        }
        info[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
        info[MPMediaItemPropertyPlaybackDuration] = Double(self.playedModel?.model.duration ?? 0)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(current)
        info[MPMediaItemPropertyTitle] = self.playedModel?.model.title ?? ""
        info[MPMediaItemPropertyArtist] = self.playedModel?.model.artist ?? ""
        info[MPMediaItemPropertyIsExplicit] = self.playedModel?.model.isExplicit ?? false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /*
     * control player
     */
    private func playOrPause()
    {
        if self.audioPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    private func audioTrackFinished()
    {
        if self.isRepeatAudio()
        {
            self.seek(value: .zero)
            self.player?.play()
            return
        }
        
        self.audioTrackNext()
    }
    
    private func audioTrackNext()
    {
        if self.isRandomAudio() {
            let randomIndex = Int.random(in: 0..<self.playerList.count - 1)
            let audio = self.playerList[randomIndex]
            self.startStream(model: audio)
            return
        }
        
        if let index = self.playerList.firstIndex(where: {$0.id == self.playedModel?.id}) {
            let next = index + 1 > self.playerList.count - 1 ? 0 : index + 1
            let audio = self.playerList[next]
            self.startStream(model: audio)
        }
    }
    
    private func audioTrackPrevious()
    {
        if self.currentTime() >= 5
        {
            self.seek(value: .zero)
            return
        }
        
        if self.isRandomAudio() {
            let randomIndex = Int.random(in: 0..<self.playerList.count - 1)
            let audio = self.playerList[randomIndex]
            self.startStream(model: audio)
            return
        }
        
        if let index = self.playerList.firstIndex(where: {$0.id == self.playedModel?.id}) {
            let previous = index - 1 < 0 ? self.playerList.count - 1 : index - 1
            let audio = self.playerList[previous]
            self.startStream(model: audio)
        }
    }
    
    /*
     * Data base
     */
    
    func receiveAudioList()
    {
        self.requestReceiveId = self.DB.receiveAudioList(delegate: self)
    }
    
    func addAudioToDB(model: AudioStruct)
    {
        self.requestAddId = self.DB.addAudio(model: model.model, delegate: self)
    }
    
    func deleteAudioFromDB(audioId: String)
    {
        self.requestDeleteId = self.DB.deleteAudio(audioId: audioId, delegate: self)
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
    
    func onAudioAdded(requestIdentifier: Int64, model: AudioModel?)
    {
        if self.requestAddId == requestIdentifier
        {
            DispatchQueue.main.async {
                if let model = model
                {
                    self.audioList.insert(AudioStruct(model: model), at: 0)
                    Toast.shared.show(text: "Added to your data base")
                } else {
                    Toast.shared.show(text: "Not added to your data base")
                }
            }
        }
    }
    
    func onAudioDeleted(requestIdentifier: Int64, audioId: String) {
        if self.requestDeleteId == requestIdentifier
        {
            DispatchQueue.main.async {
                if let index = self.audioList.firstIndex(where: {$0.model.audioId == audioId}) {
                    self.audioList.remove(at: index)
                }
            }
        }
    }
}

extension AVPlayer
{
    func addProgressObserver(action:@escaping ((Float, Float) -> Void)) -> Any {
        return self.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { time in
            if let duration = self.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                action(Float(time), Float(duration))
            }
        })
    }
}
