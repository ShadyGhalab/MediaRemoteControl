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
import UIKit
import AVFoundation

public struct MediaItem {
    let mediaTitle: String
    let mediaDescription: String
    let mediaNumber: Int?
    let mediaArtwork: UIImage?
    let mediaArtworkSize: CGSize
    let mediaDuration: CMTime
    var skipForwardInterval: NSNumber?
    var skipBackwardInterval: NSNumber?
    var brandName: String?
    
   public init(mediaTitle: String, mediaDescription: String,
         mediaNumber: Int?, mediaDuration: CMTime,
         mediaArtwork: UIImage? = UIImage(named:"Defaults"),
         mediaArtworkSize: CGSize, brandName: String?,
         skipInterval: NSNumber
         ) {
        
        self.mediaTitle = mediaTitle
        self.mediaDescription = mediaDescription
        self.mediaNumber = mediaNumber
        self.mediaArtwork = mediaArtwork
        self.mediaArtworkSize = mediaArtworkSize
        self.mediaDuration = mediaDuration
        self.skipForwardInterval = skipInterval
        self.skipBackwardInterval = skipInterval
        self.brandName = brandName
    }
}
