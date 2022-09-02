//
//  AudioPlayerItem.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 28.08.2022.
//

import AVFoundation
import SwiftUI

enum AudioPlayerItemStatus
{
    case Started
    case Stalled
    case Finished
    case Failed
}

protocol AudioPlayerItemDelegate
{
    func onStatus(status: AudioPlayerItemStatus)
}

class AudioPlayerItem: AVPlayerItem
{
    private let loader = AudioPlayerLoader()
    private var delegate: AudioPlayerItemDelegate? = nil
    
    init(data: Data, delegate: AudioPlayerItemDelegate?)
    {
        guard let url = URL(string: "audioPlayerScheme://musapp/file.mp3") else {
            fatalError("Local URL bad")
        }
        
        self.delegate = delegate
        self.loader.audioData = data
        
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self.loader, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        
        self.addObservers()
    }
    
    init(url: URL, delegate: AudioPlayerItemDelegate?)
    {
        self.delegate = delegate
        self.loader.audioData = nil
        
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self.loader, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        
        self.addObservers()
    }
    
    deinit
    {
        self.clear()
    }
    
    func clear()
    {
        self.loader.clear()
        
        removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        NotificationCenter.default.removeObserver(self)
        
        print("AudioPlayerItem: cleared")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath == #keyPath(AVPlayerItem.status) {
            self.delegate?.onStatus(status: status == .readyToPlay ? .Started : .Failed)
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func addObservers()
    {
        addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled),
                                               name: .AVPlayerItemPlaybackStalled, object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc
    private func playbackFinished() {
        self.delegate?.onStatus(status: .Finished)
    }
    
    @objc
    private func playbackStalled() {
        self.delegate?.onStatus(status: .Stalled)
    }
    
    internal class AudioPlayerLoader: NSObject, AVAssetResourceLoaderDelegate
    {
        var audioData: Data? = nil
        
        deinit
        {
            self.clear()
        }
        
        func clear()
        {
            self.audioData?.removeAll()
            self.audioData = nil
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool
        {
            guard let audioData = self.audioData, let dataRequest = loadingRequest.dataRequest else {
                return false
            }

            loadingRequest.contentInformationRequest?.contentType = "audio/mpeg"
            loadingRequest.contentInformationRequest?.contentLength = Int64(audioData.count)
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            
            if self.setDataRespond(dataRequest) {
                loadingRequest.finishLoading()
            }
            else {
                return false
            }
            
            return true
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            
        }
        
        func setDataRespond(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool
        {
            guard let audioData = self.audioData else {
                return false
            }
            
            let startOffset = dataRequest.currentOffset != 0 ?
                              Int(dataRequest.currentOffset) :
                              Int(dataRequest.requestedOffset)
            
            if (audioData.count < startOffset) {
                return false
            }
            
            let requestedLength = dataRequest.requestedLength
            let unreadBytes = audioData.count - startOffset
            let numberOfBytes = min(requestedLength, unreadBytes)
            
            let range = Range(uncheckedBounds: (lower: startOffset, upper: startOffset + numberOfBytes))
            let respond = audioData.subdata(in: range)
            dataRequest.respond(with: respond)
            
            let endOffset = startOffset + requestedLength
            return audioData.count >= endOffset
        }
    }
}
