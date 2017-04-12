/* The MIT License (MIT)
 *
 * Copyright (c) 2017 Shady Ghalab (shadyghalab)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 ## How to use:

    1- Enable the background modes for "audio, airplay and picture in picture"
    2- Create your MediaItem.
    3- Initialize the RemoteControlManager with your mediaItem.
    4- Enjoy it 😎.
 */

import Foundation
import MediaPlayer

public class RemoteControlManager: NSObject, RemoteControlActions {

    fileprivate var mediaItem: MediaItem? {
        didSet {
            setupAudioSession()
            setupRemoteCommandCenter()
            registerForApplicationStatus()
            updateNowPlayingInfo()
        }
    }
        
    public var didTapPlay: (() -> ())?
    public var didTapPause: (() -> ())?
    public var didTapNext: (() -> ())?
    public var didTapPrevious: (() -> ())?
    public var didTapSeekForward: (() -> ())?
    public var didTapSeekBackward: (() -> ())?
    public var didTapSkipForward: ((TimeInterval) -> (CMTime))?
    public var didTapSkipBackward: ((TimeInterval) -> (CMTime))?
    public var didPlaybackPositionChange: ((TimeInterval) -> ())?
    
    public var didAudioSessionRouteChange: ((AVAudioSessionRouteDescription) -> ())?
    public var didAnotherAppPrimaryAudioStart: (() -> ())?
    public var didAnotherAppPrimaryAudioStop: (() -> ())?
    public var didSessionInterruptionRouteEnd: (() -> ())?
    
    public init(with mediaItem: MediaItem) {
        super.init()
        
        defer {
             self.mediaItem = mediaItem
        }
    }
    
    
    fileprivate func setupRemoteCommandCenter() {
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.skipForwardCommand.preferredIntervals = [mediaItem?.skipInterval ?? 10]
        commandCenter.skipBackwardCommand.preferredIntervals = [mediaItem?.skipInterval ?? 10]
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.didTapPlay?()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.didTapPause?()
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            if let seekForwardEvent = event as? MPSkipIntervalCommandEvent,
                let currentTime = self?.didTapSkipForward?(seekForwardEvent.interval) {
                self?.updatePlaybackCursor(currentTime: currentTime, withForwardSeekCommand: true)
            }
            return .success
        }
       
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let seekBackwardEvent = event as? MPSkipIntervalCommandEvent,
                let currentTime = self?.didTapSkipBackward?(seekBackwardEvent.interval){
                self?.updatePlaybackCursor(currentTime: currentTime, withForwardSeekCommand: false)
            }
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            self?.didTapSeekForward?()
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            self?.didTapSeekBackward?()
            return .success
        }
        
        if #available(iOS 9.1, *) {
            commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
                if let playbackEvent = event as? MPChangePlaybackPositionCommandEvent {
                    self?.didPlaybackPositionChange?(playbackEvent.positionTime)
                }
                return .success
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func updatePlaybackCursor(currentTime time: CMTime, withForwardSeekCommand isForward: Bool) {
        let skipInterval = mediaItem?.skipInterval?.doubleValue ?? 0.0
        let elapsedTime = CMTimeGetSeconds(time) + (isForward ? skipInterval : -skipInterval)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    }
    
    fileprivate func updateNowPlayingInfo() {
        guard let mediaItem = mediaItem else { return }
       
        var nowPlayingInfo: [String : Any] = [:]
                
        setMediaArtworkIfNeeded(nowPlayingInfo: &nowPlayingInfo)
        
        nowPlayingInfo[MPMediaItemPropertyTitle] =  mediaItem.title
        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.tvShow.rawValue
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(mediaItem.duration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "\(mediaItem.brandName) - S\(mediaItem.numbers.season) Ep\(mediaItem.numbers.episode)-\(mediaItem.description)"
       
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setMediaArtworkIfNeeded(nowPlayingInfo: inout [String : Any]) {
        guard let imageArt = mediaItem?.artwork, let size = mediaItem?.artworkSize else { return }
        var mediaArt: MPMediaItemArtwork?
      
        if #available(iOS 10.0, *) {
            mediaArt = MPMediaItemArtwork(boundsSize: size, requestHandler: { (size) -> UIImage in
                return imageArt
            })
        } else {
            mediaArt = MPMediaItemArtwork(image: imageArt)
        }
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArt
    }
 
    deinit {
        tearDownAudioSession()
    }
}

extension RemoteControlManager: AudioSessionActions {

    fileprivate func setupAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChange), name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionSilenceSecondaryAudioHint), name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption), name: .AVAudioSessionInterruption, object: nil)
    }
    
    func audioSessionRouteChange() {
        self.didAudioSessionRouteChange?(AVAudioSession.sharedInstance().currentRoute)
    }
    
    func audioSessionSilenceSecondaryAudioHint(notification: Notification) {
        guard let rawValue = notification.userInfo?[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt else { return }
        let why = AVAudioSessionSilenceSecondaryAudioHintType(rawValue: rawValue)
        if why == .begin {
            self.didAnotherAppPrimaryAudioStart?()
        } else {
            self.didAnotherAppPrimaryAudioStop?()
        }
    }
    
    func audioSessionInterruption(notification: Notification) {
        guard let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        let why = AVAudioSessionInterruptionType(rawValue: rawValue)
        if why == .began {
            print("interruption began:\n\(notification.userInfo)")
        } else if let userInfo = notification.userInfo, let opt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt, AVAudioSessionInterruptionOptions(rawValue:opt).contains(.shouldResume) {
            self.didSessionInterruptionRouteEnd?()
        }
    }
    
    fileprivate func registerForApplicationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    func applicationDidBecomeActive() {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func tearDownAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
    }
}
