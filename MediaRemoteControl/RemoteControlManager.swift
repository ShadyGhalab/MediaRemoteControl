//
//  LockedMediaManager.swift
//  LockScreen
//
//  Created by Shady Ghalab on 12/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import MediaPlayer

class RemoteControlManager: NSObject, RemoteControlActions, AudioSessionActions {

    var mediaItem: MediaItem?
    
    var didTapPlay: (() -> ())?
    var didTapPause: (() -> ())?
    var didTapNext: (() -> ())?
    var didTapPrevious: (() -> ())?
    var didSeekForward: (() -> ())?
    var didSeekBackward: (() -> ())?
    var didSkipForward: ((Double?) -> ())?
    var didSkipBackward: ((Double?) -> ())?
    var didPlaybackPositionChanged: ((TimeInterval) -> ())?
    
    var didAudioSessionRouteChanged: ((AVAudioSessionRouteDescription) -> ())?
    var didAnotherAppPrimaryAudioStart: (() -> ())?
    var didAnotherAppPrimaryAudioStop: (() -> ())?
    var didSessionInterruptionRoute: ((Bool) -> ())?
    
     init(with mediaItem: MediaItem) {
        super.init()
       
        self.mediaItem = mediaItem
                
        setupAudioSession()
        setupRemoteCommandCenter()
        registerForApplicationStatus()
        updateNowPlayingInfo()
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
            let why = AVAudioSessionSilenceSecondaryAudioHintType(rawValue: n.userInfo![AVAudioSessionSilenceSecondaryAudioHintTypeKey] as! UInt)!
            if why == .begin {
                self?.didAnotherAppPrimaryAudioStart?()
            } else {
                self?.didAnotherAppPrimaryAudioStop?()
            }
        }
                
        NotificationCenter.default.addObserver(forName: .AVAudioSessionInterruption, object: nil, queue: nil) { [weak self]
            n in
            let why = AVAudioSessionInterruptionType(rawValue:
                n.userInfo![AVAudioSessionInterruptionTypeKey] as! UInt)!
            if why == .began {
                print("interruption began:\n\(n.userInfo!)")
            } else {
                print("interruption ended:\n\(n.userInfo!)")
                guard let opt = n.userInfo![AVAudioSessionInterruptionOptionKey] as? UInt else {return}
                self?.didSessionInterruptionRoute?(AVAudioSessionInterruptionOptions(rawValue:opt).contains(.shouldResume))
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
        commandCenter.skipForwardCommand.preferredIntervals = [mediaItem?.skipForwardIntervals ?? 30]
        commandCenter.skipBackwardCommand.preferredIntervals = [mediaItem?.skipBackwardIntervals ?? 30]

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
            self?.didSkipBackward?(self?.mediaItem?.skipForwardIntervals.doubleValue)
            return .success
        }
       
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            self?.didSkipForward?(self?.mediaItem?.skipBackwardIntervals.doubleValue)
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
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let playbackEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.didPlaybackPositionChanged?(playbackEvent.positionTime)
            }
            return .success
        }
    }
    
    func registerForApplicationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc fileprivate func applicationDidBecomeActive() {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func updateNowPlayingInfo() {
        guard let mediaItem = mediaItem else { return }
       
        let infoCenter = MPNowPlayingInfoCenter.default()
        let mediaArt = MPMediaItemArtwork(boundsSize: mediaItem.mediaArtworkSize, requestHandler: { (size) -> UIImage in
            return  UIImage(named:"Default")!
        })
        
        let nowPlayingInfo: [String : Any] = [
            MPMediaItemPropertyTitle : mediaItem.mediaTitle,
            MPMediaItemPropertyMediaType : MPMediaType.tvShow.rawValue,
            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(mediaItem.mediaDuration) ,
            MPMediaItemPropertyArtwork:mediaArt,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
           
        infoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    deinit {
        tearDownAudioSession()
    }
    
}
