//
//  AudioSessionActions.swift
//  LockScreen
//
//  Created by Shady Ghalab on 15/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import MediaPlayer

protocol AudioSessionActions {
    
    /// This will be called when a route change has occurred.
    var didAudioSessionRouteChanged: ((AVAudioSessionRouteDescription) -> ())? { get set }
    
    /// Use control center to test, e.g. start and stop a Music song When your app in the foreground.
    /// This will be called when the system is indicating that another application's primary audio has started.
    var didAnotherAppPrimaryAudioStart: (() -> ())? { get set }
    
    /// Use control center to test, e.g. start and stop a Music song When your app in the foreground.
    /// This will be called when the system is indicating that another application's primary audio has stopped.
    var didAnotherAppPrimaryAudioStop: (() -> ())? { get set }

    /// This will be called when the route changes from some kind of Headphones to Built-In Speaker,
    /// we should pause our sound (doesn't happen automatically)
    var didSessionInterruptionRoute: ((Bool) -> ())? { get set }
}
