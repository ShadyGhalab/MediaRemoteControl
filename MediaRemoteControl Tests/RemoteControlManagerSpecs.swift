//
//  RemoteControlManager.swift
//  MediaRemoteControl
//
//  Created by Shady Ghalab on 15/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Quick
import Nimble
import CoreMedia
import MediaPlayer
@testable import MediaRemoteControl

class RemoteControlManagerSpecs: QuickSpec {
    
    var remoteControlManager: RemoteControlManager!
    var mediaItem: MediaItem!
    
    override func spec() {
      
        beforeEach {

            self.mediaItem = MediaItem(mediaTitle: "Teacher",
                                       mediaDescription: "Six elementary school teachers",
                                       mediaNumber: 5,
                                       mediaDuration: CMTimeMake(30, 1),
                                       mediaArtwork: UIImage(named: ""),
                                       mediaArtworkSize: CGSize(width: 300, height: 300))
            
            self.remoteControlManager = RemoteControlManager(with: self.mediaItem)
        }
        
        describe("setupAudioSession") {
            
            context("When the mediaItem initlized") {
               
                it("should the Audio session's category be AVAudioSessionCategoryPlayback") {
                  expect(AVAudioSession.sharedInstance().category) == AVAudioSessionCategoryPlayback
                }
            }
            
            context("route change has occurred") {
                it("should the didAudioSessionRouteChanged is dispatched with the route description - Speaker Mode") {
                    var isAudioRouteChanged = false
                    var portType: String?
                    var portName: String?

                    self.remoteControlManager.didAudioSessionRouteChanged = { routeDescription in
                        isAudioRouteChanged = true
                        portType = routeDescription.outputs.first?.portType
                        portName = routeDescription.outputs.first?.portName
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionRouteChange, object: nil)
                    expect(isAudioRouteChanged) == true
                    expect(portType) == AVAudioSessionPortBuiltInSpeaker
                    expect(portName) == AVAudioSessionPortBuiltInSpeaker
                }                
            }
            
            context("Another application's primary audio has started while your app in the foreground") {
                it("should the didAnotherAppPrimaryAudioStart is dispatched") {
                    var isAnotherPrimaryAudioStart = false
                    
                    self.remoteControlManager.didAnotherAppPrimaryAudioStart = { routeDescription in
                        isAnotherPrimaryAudioStart = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil, userInfo: [AVAudioSessionSilenceSecondaryAudioHintTypeKey: AVAudioSessionSilenceSecondaryAudioHintType.begin.rawValue])
                    expect(isAnotherPrimaryAudioStart) == true
                }
            }
            
            context("Another application's primary audio has ended while your app in the foreground") {
                it("should the didAnotherAppPrimaryAudioStop is dispatched") {
                    var isAnotherPrimaryAudioStop = false
                    
                    self.remoteControlManager.didAnotherAppPrimaryAudioStop = { routeDescription in
                        isAnotherPrimaryAudioStop = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil, userInfo: [AVAudioSessionSilenceSecondaryAudioHintTypeKey: AVAudioSessionSilenceSecondaryAudioHintType.end.rawValue])
                    expect(isAnotherPrimaryAudioStop) == true
                }
            }
            
            context("Audio session Interruption") {
                it("should resume your media playback") {
                    var canResumePlayback = false
                    
                    self.remoteControlManager.didSessionInterruptionRouteEnd = {
                        canResumePlayback = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionInterruption, object: nil, userInfo: [AVAudioSessionInterruptionOptionKey: AVAudioSessionInterruptionOptions.shouldResume.rawValue, AVAudioSessionInterruptionTypeKey: AVAudioSessionInterruptionType.ended.rawValue])
                    expect(canResumePlayback) == true
                }
            }
        }
    }
}

