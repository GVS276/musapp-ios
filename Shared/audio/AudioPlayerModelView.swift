//
//  AudioPlayerModelView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import AVFoundation
import MediaPlayer
import SwiftUI

enum PlayerControl: Int
{
    case Next = 0,
         Previous,
         PlayOrPause
}

class AudioPlayerModelView: ObservableObject
{
    @Published var playerSheet: Bool = false
    @Published var playedModel: AudioModel? = nil
    
    @Published var audioPlaying = false
    @Published var audioPlayerReady = false
    
    @Published var audioList: [AudioModel] = []
    
    private let mediaCenter = MPNowPlayingInfoCenter.default()
    private var mediaFinished = false
    
    private var player: AudioPlayer? = nil
    private var playerCurrentTime: ((_ current: Float) -> Void)? = nil
    private var playerList: [AudioModel] = []
    
    private let DB = DBController.shared
    private var requestReceiveId: Int64? = nil
    private var requestAddId: Int64? = nil
    private var requestDeleteId: Int64? = nil
    private var requestDeleteFromDownloadId: Int64? = nil
    private var requestDownloadId: Int64? = nil
    
    init() {
        self.receiveAudioList()
    }
    
    deinit {
        self.destroy()
    }
    
    func setPlayerList(list: [AudioModel])
    {
        if !self.playerList.elementsEqual(list) {
            self.playerList.removeAll()
            self.playerList.append(contentsOf: list)
        }
    }
    
    func startStream(model: AudioModel)
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
            
            // player init
            self.playedModel = model
            self.player = AudioPlayer(model: model, delegate: self)
            
            // info (about track)
            self.initPlayingCenter()
            
            self.ready(value: true)
        } catch {
            self.ready(value: false)
        }
    }
    
    private func setAudioPlaying(value: Bool)
    {
        self.audioPlaying = value
        self.updatePlayingCenterTime(time: self.currentTime())
    }
    
    private func ready(value: Bool)
    {
        self.audioPlayerReady = value
    }
    
    private func destroy()
    {
        self.audioPlaying = false
        
        self.playerCurrentTime?(0)
        self.player?.release()
        self.player = nil

        self.playedModel = nil
    }
    
    private func setStatusDownload(audioId: String, value: Bool)
    {
        if let index = self.audioList.firstIndex(where: {$0.audioId == audioId})
        {
            self.audioList[index].isDownloaded = value
        }
        
        if let index = self.playerList.firstIndex(where: {$0.audioId == audioId})
        {
            self.playerList[index].isDownloaded = value
        }
        
        if self.playedModel?.audioId == audioId {
            self.playedModel?.isDownloaded = value
        }
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
    
    func download(model: AudioModel)
    {
        self.requestDownloadId = AudioDownload(urlString: model.streamUrl, audioId: model.audioId,
                                               delegate: self).execute()
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
    
    private func initPlayingCenter()
    {
        var info = [String : Any]()
        
        if let img = ThumbCacheObj.cache[self.playedModel?.albumId ?? ""]
        {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { size in
                return img.imageWith(newSize: size)
            }
        }
        
        info[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
        
        info[MPMediaItemPropertyTitle] = self.playedModel?.title ?? ""
        info[MPMediaItemPropertyArtist] = self.playedModel?.artist ?? ""
        info[MPMediaItemPropertyIsExplicit] = self.playedModel?.isExplicit ?? false
        
        info[MPMediaItemPropertyPlaybackDuration] = Double(self.playedModel?.duration ?? 0)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(0)
        info[MPNowPlayingInfoPropertyPlaybackRate] = Double(0)
        
        mediaCenter.nowPlayingInfo = info
    }
    
    private func updatePlayingCenterTime(time: Float)
    {
        mediaCenter.nowPlayingInfo?.updateValue(Double(time),
                                                forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        mediaCenter.nowPlayingInfo?.updateValue(Double(self.audioPlaying ? 1.0 : 0.0),
                                                forKey: MPNowPlayingInfoPropertyPlaybackRate)
    }
    
    private func clearPlayingCenterProgress()
    {
        mediaCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nil
        mediaCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = nil
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
        self.mediaFinished = false
        
        if self.isRepeatAudio()
        {
            self.clearPlayingCenterProgress()
            self.seek(value: .zero)
            self.play()
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
            self.updatePlayingCenterTime(time: 0)
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
    
    func isAddedAudio(audioId: String) -> Bool
    {
        return self.audioList.firstIndex(where: { $0.audioId == audioId }) != nil
    }
    
    func receiveAudioList()
    {
        self.requestReceiveId = self.DB.receiveAudioList(delegate: self)
    }
    
    func addAudioToDB(model: AudioModel)
    {
        self.requestAddId = self.DB.addAudio(model: model, delegate: self)
    }
    
    func deleteAudioFromDB(audioId: String)
    {
        self.requestDeleteId = self.DB.deleteAudio(audioId: audioId, delegate: self)
    }
    
    func deleteAudioFromDownload(audioId: String)
    {
        self.requestDeleteFromDownloadId = self.DB.deleteAudioFromDownload(audioId: audioId, delegate: self)
    }
}

extension AudioPlayerModelView: IDBDelegate
{
    func onAudioList(requestIdentifier: Int64, list: Array<AudioModel>?)
    {
        if self.requestReceiveId == requestIdentifier
        {
            DispatchQueue.main.async {
                if let list = list
                {
                    self.audioList = list
                }
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
                    self.audioList.insert(model, at: 0)
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
                if let index = self.audioList.firstIndex(where: {$0.audioId == audioId}) {
                    self.audioList.remove(at: index)
                }
            }
        }
    }
    
    func onAudioFromDownloadDeleted(requestIdentifier: Int64, audioId: String) {
        if self.requestDeleteFromDownloadId == requestIdentifier
        {
            DispatchQueue.main.async {
                self.setStatusDownload(audioId: audioId, value: false)
            }
        }
    }
}

extension AudioPlayerModelView: AudioPlayerItemDelegate
{
    func onStatus(status: AudioPlayerItemStatus) {
        switch status {
        case .None:
            print("Audio: None")
        case .Ready:
            self.play()
        case .Paused:
            if self.mediaFinished
            {
                self.audioTrackFinished()
            } else {
                self.setAudioPlaying(value: false)
            }
        case .Playing:
            self.setAudioPlaying(value: true)
        case .Buffering:
            print("Audio: Buffering")
        case .MinimizeStalls:
            print("Audio: MinimizeStalls")
        case .Finished:
            self.mediaFinished = true
        case .Failed:
            print("Audio: Failed")
        }
    }
    
    func onCurrentPosition(seconds: Float) {
        if let handler = self.playerCurrentTime
        {
            handler(seconds)
        }
    }
    
    func onAudioUnavailable() {
        print("Audio: unavailable")
        Toast.shared.show(text: "Track is unavailable or has been blocked")
    }
}

extension AudioPlayerModelView: DownloadDelegate
{
    func onDownload(requestIdentifier: Int64, audioId: String, status: AudioDownloadStatus)
    {
        switch status {
        case .Started:
            print("Audio: Downloading...")
        case .Finished:
            self.DB.setDownloaded(audioId: audioId, value: true)

            DispatchQueue.main.async {
                self.setStatusDownload(audioId: audioId, value: true)
            }
            
            print("Audio: Downloaded")
        case .Failed:
            print("Audio: Downloading failed")
        }
    }
}
