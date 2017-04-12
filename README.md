# MediaRemoteControl 


MediaRemoteControl is a framework that can handle the media using the external controls (play, pause, skipInterval, seekInterval,etc..) 
from the remote control and control center. Written in Swift 3.0


### When to use:
You can use this framework when you want the user to use the external controls (remote control and control center) to manipulate
the player (play,pause, etc..). for instance: when the user is watching media in your app then the user locked the screen so he still can
play the media through the external control. This is useful when the user want to play/pause his media from external controls
that is shared with AirPlay without putting the app in the foreground.


### Installation:
## Carthage

``` github "ShadyGhalab/MediaRemoteControl" "0.1.1" ```

## Cocoapods

``` pod 'MediaRemoteControl', '0.1.1' ```

## How to use

```
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
```
    
    
### Screenshots

![alt tag](http://i66.tinypic.com/2dadbhh.png)
![alt tag](http://i63.tinypic.com/24d1ysi.png)
