//
//  ViewController.swift
//  LockScreen
//
//  Created by Shady Ghalab on 12/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var remoteControlManager: RemoteControlManager?
    let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()

        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: videoURL!)
        playerViewController.player = player
        if #available(iOS 10.0, *) {
            playerViewController.updatesNowPlayingInfoCenter = false
        } else {
            // Fallback on earlier versions
        }
       
        setupRemoteControlMediaActions()
        
        self.present(playerViewController, animated: true) {
            self.playerViewController.player!.play()
        }
    }
    
    func setupRemoteControlMediaActions() {
        
        let mediaItem = MediaItem(mediaTitle: "Teacher", mediaDescription: "Play with his kids!", mediaNumber: 5, mediaDuration: (self.playerViewController.player?.currentItem?.asset.duration)!, mediaArtwork: nil, mediaArtworkSize: CGSize(width: 200, height: 200))
        
        remoteControlManager = RemoteControlManager(with: mediaItem)

        remoteControlManager?.didTapPlay = { [weak self] in
            self?.playerViewController.player!.play()
        }
        
        remoteControlManager?.didTapPause = { [weak self] in
            self?.playerViewController.player!.pause()
        }
        
        remoteControlManager?.didSkipForward = { [weak self] skipForwardInterval in
            self?.playerViewController.player!.seek(to: CMTimeSubtract((self?.playerViewController.player!.currentTime())!, CMTimeMakeWithSeconds(skipForwardInterval, (self?.playerViewController.player!.currentTime().timescale)!)))
        }
        
        remoteControlManager?.didSkipBackward = { [weak self] skipBackwardInterval in
            self?.playerViewController.player!.seek(to: CMTimeSubtract((self?.playerViewController.player!.currentTime())!, CMTimeMakeWithSeconds(skipBackwardInterval, (self?.playerViewController.player!.currentTime().timescale)!)))
        }
        
        remoteControlManager?.didPlaybackPositionChanged = { [weak self] positionTime in
            self?.playerViewController.player?.seek(to: CMTimeMakeWithSeconds(positionTime, 1000000))
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

