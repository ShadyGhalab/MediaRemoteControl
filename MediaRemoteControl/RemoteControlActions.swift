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
    var didPlaybackPositionChange:((TimeInterval) -> ())? { get }
}
