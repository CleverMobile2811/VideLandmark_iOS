//
//  CustomVideoInfo.swift
//  TestVideo
//
//  Created by Clever on 25/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import Foundation
import  UIKit

class CustomVideoInfo {
    var videoURL : URL?
    var temporaryVideoURL : URL?
    var sourceImage : UIImage?
    var thumbnailImage: UIImage?
    var startTime : Float64 = 0.0
    var endTime : Float64 = 0.0
    var range : Float64 = 0.0
    var isFirstAssetPortrait = false
    var naturalSize : CGSize?
    var dstSize = CGSize()
    var scale : CGFloat = 1.0
}
