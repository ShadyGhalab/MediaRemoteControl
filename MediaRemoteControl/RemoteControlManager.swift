//
//  LockedMediaManager.swift
//  MediaRemoteControll
//
//  Created by Shady Ghalab on 12/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import MediaPlayer

class RemoteControlManager: NSObject, RemoteControlActions, AudioSessionActions {

    fileprivate var mediaItem: MediaItem? {
        didSet {
            setupAudioSession()
            setupRemoteCommandCenter()
            registerForApplicationStatus()
            updateNowPlayingInfo()
        }
    }
    
    var didTapPlay: (() -> ())?
    var didTapPause: (() -> ())?
    var didTapNext: (() -> ())?
    var didTapPrevious: (() -> ())?
    var didSeekForward: (() -> ())?
    var didSeekBackward: (() -> ())?
    var didSkipForward: ((TimeInterval) -> ())?
    var didSkipBackward: ((TimeInterval) -> ())?
    var didPlaybackPositionChanged: ((TimeInterval) -> ())?
    
    var didAudioSessionRouteChanged: ((AVAudioSessionRouteDescription) -> ())?
    var didAnotherAppPrimaryAudioStart: (() -> ())?
    var didAnotherAppPrimaryAudioStop: (() -> ())?
    var didSessionInterruptionRouteEnd: (() -> ())?
    
     init(with mediaItem: MediaItem) {
        super.init()
        
        defer {
             self.mediaItem = mediaItem
        }
    }
    
    fileprivate func setupAudioSession() {
       
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        NotificationCenter.default.addObserver(forName: .AVAudioSessionRouteChange, object: nil, queue: nil) { [weak self]
            n in
               self?.didAudioSessionRouteChanged?(AVAudioSession.sharedInstance().currentRoute)
        }
        
        NotificationCenter.default.addObserver(forName: .AVAudioSessionSilenceSecondaryAudioHint,
                                               object: nil, queue: nil) { [weak self]
            n in
            guard let rawValue = n.userInfo?[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt else { return }
            let why = AVAudioSessionSilenceSecondaryAudioHintType(rawValue: rawValue)
            if why == .begin {
                self?.didAnotherAppPrimaryAudioStart?()
            } else {
                self?.didAnotherAppPrimaryAudioStop?()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .AVAudioSessionInterruption, object: nil, queue: nil) { [weak self]
            n in
            guard let rawValue = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
            let why = AVAudioSessionInterruptionType(rawValue: rawValue)
            if why == .began {
                print("interruption began:\n\(n.userInfo!)")
            } else if let userInfo = n.userInfo, let opt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt, AVAudioSessionInterruptionOptions(rawValue:opt).contains(.shouldResume) {
                self?.didSessionInterruptionRouteEnd?()
            }
        }
    }
    
    fileprivate func tearDownAudioSession() {
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
    
    fileprivate func setupRemoteCommandCenter() {
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
      
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [mediaItem?.skipForwardIntervals ?? 10]
        commandCenter.skipBackwardCommand.preferredIntervals = [mediaItem?.skipBackwardIntervals ?? 10]

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true

        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.isEnabled = true
       
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.didTapPlay?()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.didTapPause?()
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            if let seekForwardEvent = event as? MPSkipIntervalCommandEvent {
                self?.didSkipBackward?(seekForwardEvent.interval)
            }
            return .success
        }
       
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let seekBackwardEvent = event as? MPSkipIntervalCommandEvent {
                self?.didSkipForward?(seekBackwardEvent.interval)
            }
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            self?.didSeekForward?()
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            self?.didSeekBackward?()
            return .success
        }
        
        if #available(iOS 9.1, *) {
            commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
                if let playbackEvent = event as? MPChangePlaybackPositionCommandEvent {
                    self?.didPlaybackPositionChanged?(playbackEvent.positionTime)
                }
                return .success
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    fileprivate func registerForApplicationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc fileprivate func applicationDidBecomeActive() {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    fileprivate func updateNowPlayingInfo() {
        guard let mediaItem = mediaItem else { return }
       
        var nowPlayingInfo: [String : Any] = [:]
        var mediaArt: MPMediaItemArtwork?
        
        let infoCenter = MPNowPlayingInfoCenter.default()
        if #available(iOS 10.0, *) {
            mediaArt = MPMediaItemArtwork(boundsSize: mediaItem.mediaArtworkSize, requestHandler: { (size) -> UIImage in
                return mediaItem.mediaArtwork ?? UIImage(named:"Default")!
            })
        } else {
            mediaArt = MPMediaItemArtwork(image: mediaItem.mediaArtwork ?? UIImage(named:"Default")!)
        }
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArt
        nowPlayingInfo[MPMediaItemPropertyTitle] = mediaItem.mediaTitle
        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.tvShow.rawValue
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(mediaItem.mediaDuration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = mediaItem.mediaDescription
        infoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    deinit {
        tearDownAudioSession()
    }
    
}
