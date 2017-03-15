//
//  ExternalPlayerActions.swift
//  LockScreen
//
//  Created by Shady Ghalab on 13/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation

protocol RemoteControlActions {
    
    /// This will be called when the user press the play button.
    var didTapPlay: (() -> ())? { get set }
    
    /// This will be called when the user press the pause button.
    var didTapPause: (() -> ())? { get set }
   
    /// This will be called when the user press the next button.
    var didTapNext: (() -> ())? { get set }
    
    /// This will be called when the user press the previous button.
    var didTapPrevious: (() -> ())? { get set }
    
    /// This will be called when the user press the seek forward button.
    var didSeekForward: (() -> ())? { get set }
    
    /// This will be called when the user press the seek backward button.
    var didSeekBackward: (() -> ())? { get set }
    
    /// This will be called when the user press the skip forward button.
    var didSkipForward: ((Double?) -> ())? { get set }
    
    /// This will be called when the user press the skip backward button.
    var didSkipBackward: ((Double?) -> ())? { get set }

    /// This will be called when the user changed the slider value.
    var didPlaybackPositionChanged:((TimeInterval) -> ())? { get set }
}
