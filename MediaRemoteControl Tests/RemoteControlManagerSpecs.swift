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

            self.mediaItem = MediaItem(withTitle: "Teacher",
                                       withDescription: "Six elementary school teachers",
                                       withMediaNumber: 5,
                                       withDuration: CMTimeMake(30, 1),
                                       artwork: UIImage(named: "Default"),
                                       artworkSize: CGSize(width: 300, height: 300),
                                       withBrand: "TV Land", skipInterval: 10)
            
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

                    self.remoteControlManager.didAudioSessionRouteChange = { routeDescription in
                        isAudioRouteChanged = true
                        portType = routeDescription.outputs.first?.portType
                        portName = routeDescription.outputs.first?.portName
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionRouteChange, object: nil)
                    expect(isAudioRouteChanged) == true
                   if #available(iOS 10.0, *) {
                        expect(portType) == AVAudioSessionPortBuiltInSpeaker
                        expect(portName) == AVAudioSessionPortBuiltInSpeaker
                    }
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
            
            context("Audio session Interruption ended") {
                it("should resume your media playback") {
                    var canResumePlayback = false
                    
                    self.remoteControlManager.didSessionInterruptionRouteEnd = {
                        canResumePlayback = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionInterruption, object: nil, userInfo: [AVAudioSessionInterruptionOptionKey: AVAudioSessionInterruptionOptions.shouldResume.rawValue, AVAudioSessionInterruptionTypeKey: AVAudioSessionInterruptionType.ended.rawValue])
                    expect(canResumePlayback) == true
                }
            }
            
            context("Audio session Interruption ended") {
                it("shouldn't resume your media playback") {
                    var canResumePlayback = false
                    
                    self.remoteControlManager.didSessionInterruptionRouteEnd = {
                        canResumePlayback = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionInterruption, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSessionInterruptionType.ended.rawValue])
                    expect(canResumePlayback) == false
                }
            }
        }
        
        describe("setupRemoteCommandCenter") {
            context("when the user tap skip command") {
                it("shoud the time interval for the command be like the time interval for the media item") {
                    let commandCenter = MPRemoteCommandCenter.shared()
                    
                    expect(commandCenter.skipForwardCommand.preferredIntervals).to(contain((self.mediaItem?.skipInterval)!), description: nil)
                    expect(commandCenter.skipBackwardCommand.preferredIntervals).to(contain((self.mediaItem?.skipInterval)!), description: nil)
                }
            }
            
            context("when the user tap skip command") {
                it("shoud the time interval for the command be like the time interval for the media item") {
                    let commandCenter = MPRemoteCommandCenter.shared()
                    self.mediaItem = MediaItem(withTitle: "Friends",
                                               withDescription: "Six elementary school teachers",
                                               withMediaNumber: 5,
                                               withDuration: CMTimeMake(50, 1),
                                               artwork: nil,
                                               artworkSize: CGSize(width: 300, height: 300),
                                               withBrand: "TV Land", skipInterval: 30)
                    
                    self.remoteControlManager = RemoteControlManager(with: self.mediaItem)

                    expect(commandCenter.skipForwardCommand.preferredIntervals).to(contain((self.mediaItem?.skipInterval)!), description: nil)
                    expect(commandCenter.skipBackwardCommand.preferredIntervals).to(contain((self.mediaItem?.skipInterval)!), description: nil)
                }
            }
        }
        
        describe("updateNowPlayingInfo") {
            context("when the mediaItem has been set") {
                it("should nowPlayingInfo has the same values from media Item") {
                    let infoCenter = MPNowPlayingInfoCenter.default()
                    
                    expect(infoCenter.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String) == self.mediaItem.title
                    expect(infoCenter.nowPlayingInfo?[MPMediaItemPropertyMediaType] as? UInt) == MPMediaType.tvShow.rawValue
                    expect(infoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] as? Float64) == CMTimeGetSeconds(self.mediaItem.duration)
                    expect(infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber) == 1.0
                    expect(infoCenter.nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] as? String) == self.mediaItem.description
                   
                    if #available(iOS 10.0, *) {
                        expect((infoCenter.nowPlayingInfo?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork)?.image(at: self.mediaItem.artworkSize)) == MPMediaItemArtwork(boundsSize: self.mediaItem.artworkSize, requestHandler: { (size) -> UIImage in
                            return self.mediaItem.artwork!
                        }).image(at: self.mediaItem.artworkSize)
                    } else {
                        expect((infoCenter.nowPlayingInfo?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork)?.image(at: self.mediaItem.artworkSize)) == MPMediaItemArtwork(image: self.mediaItem.artwork!).image(at: self.mediaItem.artworkSize)
                    }
                }
            }
        }
        
        describe("tearDownAudioSession") {
            context("when the the RemoteControlManager deinit has called") {
                
                beforeEach {
                    self.remoteControlManager.tearDownAudioSession()
                }
                
                it("should the Audio session's category be AVAudioSessionCategoryAmbient") {
                    expect(AVAudioSession.sharedInstance().category) == AVAudioSessionCategoryAmbient
                }
                
                it("shouldn't call didAudioSessionRouteChange") {
                    var isAudioRouteChanged = false
                    self.remoteControlManager.didAudioSessionRouteChange = { routeDescription in
                        isAudioRouteChanged = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionRouteChange, object: nil)
                    expect(isAudioRouteChanged) == false
                }
                
                it("shouldn't call didAnotherAppPrimaryAudioStart") {
                    var isAnotherPrimaryAudioStart = false
                    
                    self.remoteControlManager.didAnotherAppPrimaryAudioStart = { routeDescription in
                        isAnotherPrimaryAudioStart = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil, userInfo: [AVAudioSessionSilenceSecondaryAudioHintTypeKey: AVAudioSessionSilenceSecondaryAudioHintType.begin.rawValue])
                    expect(isAnotherPrimaryAudioStart) == false
                }
                
                it("shouldn't resume your media playback") {
                    var canResumePlayback = false
                    
                    self.remoteControlManager.didSessionInterruptionRouteEnd = {
                        canResumePlayback = true
                    }
                    
                    NotificationCenter.default.post(name: .AVAudioSessionInterruption, object: nil, userInfo: [AVAudioSessionInterruptionOptionKey: AVAudioSessionInterruptionOptions.shouldResume.rawValue, AVAudioSessionInterruptionTypeKey: AVAudioSessionInterruptionType.ended.rawValue])
                    expect(canResumePlayback) == false
                }
            }
        }
    }
}

