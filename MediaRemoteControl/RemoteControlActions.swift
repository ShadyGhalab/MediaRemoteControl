//
//  RemoteControlActions.swift
//  MediaRemoteControll
//
//  Created by Shady Ghalab on 13/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation

protocol RemoteControlActions: class {
    
    /// call when the user press on the play button.
    var didTapPlay: (() -> ())? { get }
    
    /// call when the user press the pause button.
    var didTapPause: (() -> ())? { get }
   
    /// call when the user press the next button.
    var didTapNext: (() -> ())? { get }
    
    /// call when the user press the previous button.
    var didTapPrevious: (() -> ())? { get }
    
    /// call when the user press the seek forward button.
    var didTapSeekForward: (() -> ())? { get }
    
    /// call when the user press the seek backward button.
    var didTapSeekBackward: (() -> ())? { get }
    
    /// call when the user press the skip forward button.
    var didTapSkipForward: ((TimeInterval) -> ())? { get }
    
    /// call when the user press the skip backward button.
    var didTapSkipBackward: ((TimeInterval) -> ())? { get }

    /// call when the user changed the slider value.
    var didPlaybackPositionChanged:((TimeInterval) -> ())? { get }
}
