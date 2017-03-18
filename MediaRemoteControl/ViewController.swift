/* The MIT License (MIT)
 *
 * Copyright (c) 2017 Shady Ghalab (ktustanowski)
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

//        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//        let player = AVPlayer(url: videoURL!)
//        playerViewController.player = player
//        if #available(iOS 10.0, *) {
//            playerViewController.updatesNowPlayingInfoCenter = false
//        } else {
//            // Fallback on earlier versions
//        }
//       
//        setupRemoteControlMediaActions()
//        
//        self.present(playerViewController, animated: true) {
//            self.playerViewController.player!.play()
//        }
    }
    
    func setupRemoteControlMediaActions() {
        
        let mediaItem = MediaItem(mediaTitle: "Teacher", mediaDescription: "Play with his kids!",
                                  mediaNumber: 5,
                                  mediaDuration: (self.playerViewController.player?.currentItem?.asset.duration)!,
                                  mediaArtwork: nil, mediaArtworkSize: CGSize(width: 200, height: 200),
                                  brandName: "TV Land", skipInterval: 5)
        
        remoteControlManager = RemoteControlManager(with: mediaItem)

        remoteControlManager?.didTapPlay = { [weak self] in
            self?.playerViewController.player!.play()
        }
        
        remoteControlManager?.didTapPause = { [weak self] in
            self?.playerViewController.player!.pause()
        }
        
        remoteControlManager?.didTapSkipForward = { [weak self] skipForwardInterval in
            self?.playerViewController.player!.seek(to: CMTimeSubtract((self?.playerViewController.player!.currentTime())!, CMTimeMakeWithSeconds(skipForwardInterval, (self?.playerViewController.player!.currentTime().timescale)!)))
        }
        
        remoteControlManager?.didTapSkipBackward = { [weak self] skipBackwardInterval in
            self?.playerViewController.player!.seek(to: CMTimeSubtract((self?.playerViewController.player!.currentTime())!, CMTimeMakeWithSeconds(skipBackwardInterval, (self?.playerViewController.player!.currentTime().timescale)!)))
        }
        
        remoteControlManager?.didPlaybackPositionChange = { [weak self] positionTime in
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

