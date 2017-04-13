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

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var remoteControlManager: RemoteControlManager?
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()

        if ProcessInfo.processInfo.environment["IN_TESTS"] == nil {
            setupRemoteControlMediaActions()
        }
    }
    
    func setupPlayer() {
        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        self.player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        player?.play()
    }
    
    func setupRemoteControlMediaActions() {
        
        let mediaItem = MediaItem(withTitle: "Teacher", withDescription: "Play with his kids!",
                                  withSeasonEpisodeNumbers: (1,5),
                                  withDuration: (player?.currentItem?.asset.duration)!,
                                  artwork: UIImage(named:"Default"), artworkSize: CGSize(width: 200, height: 200),
                                  withBrand: "TV Land", skipInterval: 10)
        
        remoteControlManager = RemoteControlManager(with: mediaItem)

        remoteControlManager?.didTapPlay = { [weak self] in
            self?.player?.play()
        }
        
        remoteControlManager?.didTapPause = { [weak self] in
            self?.player?.pause()
        }
        
        remoteControlManager?.didTapSkipForward = { [weak self] skipForwardInterval in
            self?.player?.seek(to: CMTimeAdd((self?.player?.currentTime())!, CMTimeMakeWithSeconds(skipForwardInterval, (self?.player?.currentTime().timescale)!)))
            return (self?.player?.currentTime())!
        }
        
        remoteControlManager?.didTapSkipBackward = { [weak self] skipBackwardInterval in
            self?.player?.seek(to: CMTimeSubtract((self?.player?.currentTime())!, CMTimeMakeWithSeconds(skipBackwardInterval, (self?.player?.currentTime().timescale)!)))
            return (self?.player?.currentTime())!
        }
        
        remoteControlManager?.didPlaybackPositionChange = { [weak self] positionTime in
            self?.player?.seek(to: CMTimeMakeWithSeconds(positionTime, 1000000))
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

