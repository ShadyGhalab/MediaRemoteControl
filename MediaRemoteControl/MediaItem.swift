//
//  MediaItem.swift
//  MediaRemoteControll
//
//  Created by Shady Ghalab on 12/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct MediaItem {
    let mediaTitle: String
    let mediaDescription: String
    let mediaNumber: Int?
    let mediaArtwork: UIImage?
    let mediaArtworkSize: CGSize
    let mediaDuration: CMTime
    var skipForwardInterval: NSNumber?
    var skipBackwardInterval: NSNumber?
    var brandName: String?
    
    init(mediaTitle: String, mediaDescription: String,
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
