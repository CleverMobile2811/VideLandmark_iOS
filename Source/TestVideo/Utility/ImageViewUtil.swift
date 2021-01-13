//
//  File.swift
//  TestVideo
//
//  Created by Clever on 25/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ImageViewUtil {
    static func imageWithImage(sourceImage:UIImage, selectedImageView: UIImageView, selectedBackgroundView: UIView) -> UIImage {
        let frameWidth = selectedBackgroundView.frame.width
        let frameHeight = selectedBackgroundView.frame.height
        
        let rateFrame = frameWidth / frameHeight
        let rateImage = sourceImage.size.width / sourceImage.size.height
        
        if rateFrame < rateImage {
            let oldWidth = sourceImage.size.width
            let scaleFactor = frameWidth / oldWidth
            
            let newWidth = sourceImage.size.width * scaleFactor
            let newHeight = sourceImage.size.height * scaleFactor
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
            sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            selectedImageView.frame.size.width = newWidth
            selectedImageView.frame.size.height = newHeight
            selectedImageView.frame.origin.x = (selectedBackgroundView.frame.size.width - newWidth) / 2
            return newImage!
        } else {
            let oldHeight = sourceImage.size.height
            let scaleFactor = frameHeight / oldHeight
            
            let newWidth = sourceImage.size.width * scaleFactor
            let newHeight = oldHeight * scaleFactor
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
            sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            selectedImageView.frame.size.width = newWidth
            selectedImageView.frame.size.height = newHeight
            selectedImageView.frame.origin.x = (selectedBackgroundView.frame.size.width - newWidth) / 2
            return newImage!
        }
    }
    
    static func globalImageWithImage(sourceImage:UIImage, selectedImageView: UIImageView, selectedBackgroundView: UIView) -> UIImage {
        
        let frameWidth = selectedBackgroundView.frame.width
        let frameHeight = selectedBackgroundView.frame.height
        
        let rateFrame = frameWidth / frameHeight
        let rateImage = sourceImage.size.width / sourceImage.size.height
        
        if rateFrame < rateImage {
            let oldWidth = sourceImage.size.width
            let scaleFactor = frameWidth / oldWidth
            
            let newWidth = sourceImage.size.width * scaleFactor
            let newHeight = sourceImage.size.height * scaleFactor
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
            sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            selectedImageView.frame.size.width = newWidth
            selectedImageView.frame.size.height = newHeight
            selectedImageView.frame.origin.x = (selectedBackgroundView.frame.size.width - newWidth) / 2
            selectedBackgroundView.backgroundColor = UIColor(red: 0x09, green: 0x09, blue: 0x09)
            return newImage!
        } else {
            let oldHeight = sourceImage.size.height
            let scaleFactor = frameHeight / oldHeight
            
            let newWidth = sourceImage.size.width * scaleFactor
            let newHeight = oldHeight * scaleFactor
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
            sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            selectedImageView.frame.size.width = newWidth
            selectedImageView.frame.size.height = newHeight
            selectedImageView.frame.origin.x = (selectedBackgroundView.frame.size.width - newWidth) / 2
            selectedBackgroundView.backgroundColor = UIColor(red: 0x09, green: 0x09, blue: 0x09)
            return newImage!
        }
    }
    
    static func generateThumnail(customVideoInfo: CustomVideoInfo, url : URL, fromTime:Float64) -> UIImage? {
        let asset :AVAsset = AVAsset(url: url)
        customVideoInfo.range = asset.duration.seconds
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
        let time        : CMTime = CMTimeMakeWithSeconds(fromTime, 600)
        var img: CGImage?
        do {
            img = try assetImgGenerate.copyCGImage(at:time, actualTime: nil)
        } catch {
        }
        if img != nil {
            let frameImg    : UIImage = UIImage(cgImage: img!)
            return frameImg
        } else {
            return nil
        }
    }


}
