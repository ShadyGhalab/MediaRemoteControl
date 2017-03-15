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
        }
    }


}
