//
//  LockedMediaManager.swift
//  MediaRemoteControll
//
//  Created by Shady Ghalab on 12/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import MediaPlayer

public class RemoteControlManager: NSObject, RemoteControlActions, AudioSessionActions {

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
    public var didTapSkipForward: ((TimeInterval) -> ())?
    public var didTapSkipBackward: ((TimeInterval) -> ())?
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
        self.didAudioSessionRouteChange!(AVAudioSession.sharedInstance().currentRoute)
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
    
    fileprivate func setupRemoteCommandCenter() {
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
      
        commandCenter.skipForwardCommand.preferredIntervals = [mediaItem?.skipForwardInterval ?? 10]
        commandCenter.skipBackwardCommand.preferredIntervals = [mediaItem?.skipBackwardInterval ?? 10]
        
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
                self?.didTapSkipBackward?(seekForwardEvent.interval)
            }
            return .success
        }
       
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let seekBackwardEvent = event as? MPSkipIntervalCommandEvent {
                self?.didTapSkipForward?(seekBackwardEvent.interval)
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
    
    fileprivate func updateNowPlayingInfo() {
        guard let mediaItem = mediaItem else { return }
       
        var nowPlayingInfo: [String : Any] = [:]
                
        setMediaArtworkIfNeeded(nowPlayingInfo: &nowPlayingInfo)
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = mediaItem.mediaTitle
        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.tvShow.rawValue
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(mediaItem.mediaDuration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = mediaItem.mediaDescription
       
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setMediaArtworkIfNeeded(nowPlayingInfo: inout [String : Any]) {
        guard let imageArt = mediaItem?.mediaArtwork, let size = mediaItem?.mediaArtworkSize else { return }
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
    
    deinit {
        tearDownAudioSession()
    }
    
}
