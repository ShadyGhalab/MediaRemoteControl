//
//  AudioSessionActions.swift
//  MediaRemoteControll
//
//  Created by Shady Ghalab on 15/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import MediaPlayer

protocol AudioSessionActions: class {
    
    /// call when a route change has occurred.
    var didAudioSessionRouteChange: ((AVAudioSessionRouteDescription) -> ())? { get }
    
    /// Use control center to test, e.g. start and stop a Music song When your app in the foreground.
    /// call when the system is indicating that another application's primary audio has started.
    var didAnotherAppPrimaryAudioStart: (() -> ())? { get }
    
    /// Use control center to test, e.g. start and stop a Music song When your app in the foreground.
    /// call when the system is indicating that another application's primary audio has stopped.
    var didAnotherAppPrimaryAudioStop: (() -> ())? { get }

    /// call when the route changes from some kind of Headphones to Built-In Speaker,
    /// we should pause our sound (doesn't happen automatically)
    var didSessionInterruptionRouteEnd: (() -> ())? { get }
}
