//
//  AudioPlayer.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 23.09.2022.
//

import AVFoundation

class AudioPlayer: AVPlayer
{
    private var playerItem: AudioPlayerItem? = nil
    private var periodicTime: Any? = nil
    
    override init() {
        super.init()
    }
    
    init(model: AudioModel, delegate: AudioPlayerItemDelegate?)
    {
        var playerItem: AudioPlayerItem? = nil
        
        guard let audioUrl = UIFileUtils.getAnyFileUri(path: AUDIO_PATH, fileName: "\(model.audioId).mp3") else {
            super.init(playerItem: nil)
            delegate?.onAudioUnavailable()
            return
        }
        
        if UIFileUtils.existFile(fileUrl: audioUrl)
        {
            guard let data = try? Data(contentsOf: audioUrl) else {
                super.init(playerItem: nil)
                delegate?.onAudioUnavailable()
                return
            }
            
            print("Audio: cached")
            playerItem = AudioPlayerItem(data: data, delegate: delegate)
        } else {
            guard let url = URL.init(string: model.streamUrl) else {
                super.init(playerItem: nil)
                delegate?.onAudioUnavailable()
                return
            }
            
            print("Audio: streaming")
            playerItem = AudioPlayerItem(url: url, delegate: delegate)
        }
        
        super.init(playerItem: playerItem)
        
        self.playerItem = playerItem
        
        self.addObservers()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath != #keyPath(AVPlayer.timeControlStatus)
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch timeControlStatus {
        case .paused:
            self.playerItem?.setItemStatus(itemStatus: .Paused)
            
        case .playing:
            self.playerItem?.setItemStatus(itemStatus: .Playing)
            
        case .waitingToPlayAtSpecifiedRate:
            if let reason = reasonForWaitingToPlay {
                switch reason {
                case .evaluatingBufferingRate:
                    self.playerItem?.setItemStatus(itemStatus: .Buffering)

                case .toMinimizeStalls:
                    self.playerItem?.setItemStatus(itemStatus: .MinimizeStalls)

                case .noItemToPlay:
                    self.playerItem?.setItemStatus(itemStatus: .Failed)

                default:
                    print("AudioPlayer: Unknown \(reason)")
                    self.playerItem?.setItemStatus(itemStatus: .None)
                }
            }
        default:
            print("AudioPlayer: Unknown control status")
            self.playerItem?.setItemStatus(itemStatus: .None)
        }
    }
    
    deinit
    {
        self.release()
    }
    
    func release()
    {
        if self.playerItem == nil
        {
            return
        }
        
        removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        
        if let observer = self.periodicTime
        {
            removeTimeObserver(observer)
        }
        
        self.pause()
        self.seek(to: .zero)
        
        self.playerItem?.release()
        self.playerItem = nil
    }
    
    private func addObservers()
    {
        addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: .new, context: nil)
        self.periodicTime = addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { time in
            self.playerItem?.setCurrentPosition(seconds: Float(CMTimeGetSeconds(time)))
        }
    }
}
