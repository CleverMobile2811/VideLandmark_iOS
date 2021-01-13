//
//  ProgressViewController.swift
//  TestVideo
//
//  Created by Clever on 24/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import MBProgressHUD
import UICircularProgressRing

class ProgressViewController : UIViewController {
    
    @IBOutlet weak var progressChartView: UICircularProgressRingView!
    
    var renderSize : CGSize?
    var finalTransform: CGAffineTransform?
    
    var customVideoInfo : CustomVideoInfo?
    var timer : Timer?
    var exporter : AVAssetExportSession?
    var transformedVideoURL : URL?
    var subTitleString : String?
    var numberLine = 0
    let backgroundColor = UIColor(rgb: 0x888888)
    
    // background notification
    let backgroundNotification = Notification.Name(rawValue:"BackgroundNotification")
    
    override func viewDidAppear(_ animated: Bool) {
        initTimer()
        let nc = NotificationCenter.default
        nc.addObserver(forName:backgroundNotification, object:nil, queue:nil, using:catchBackgroundNotification)
        processingVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if exporter != nil {
            exporter?.cancelExport()
        } else {
            backToProcessViewController()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
        case "previewViewController":
            let destVC                  = segue.destination as! PreviewViewController
            destVC.temporaryURL         = self.customVideoInfo?.temporaryVideoURL
            break
        default:
            break
        }
    }
    
    // init Timer
    func initTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onUpdateChart), userInfo: nil, repeats: true)
    }
    
    // update chart from status of AVAssetExportSession
    func onUpdateChart() {
        if (exporter != nil) {
            let progress = exporter?.progress
            let value = roundf(progress! * 100)
            progressChartView.setProgress(value: CGFloat(value), animationDuration: 0)
        }
    }
    
    // process video into temporary directory
    
    func processingVideo() {
        
        //temporary videoURL
        let originalFileExtension = customVideoInfo?.videoURL?.pathExtension
        let paths = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let fileUrl = paths.absoluteURL?.appendingPathComponent("test." + originalFileExtension!)
        try? FileManager.default.removeItem(at: fileUrl!)
        
        //create AVURLAsset from selected videoURL
        let videoAsset = AVURLAsset.init(url: (customVideoInfo?.videoURL)!)
        let mixComposition = AVMutableComposition.init()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        try? compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: clipVideoTrack, at: kCMTimeZero)
        
        let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let clipAudioTrack = videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        try? compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: clipAudioTrack, at: kCMTimeZero)
        
        let sizeOfVideo =  renderSize!
        
        //TextLayer defines the text they want to add in Video
        
        // Test of subtitle
        let textOfVideo = CATextLayer.init()
        
        textOfVideo.string = subTitleString
        textOfVideo.font = CFBridgingRetain("Helvetica-Regular")
        textOfVideo.fontSize = 16
        let fixedSize = 40 - numberLine * 8
        textOfVideo.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height - CGFloat(fixedSize))
        textOfVideo.alignmentMode = kCAAlignmentCenter
        textOfVideo.foregroundColor = UIColor.white.cgColor

        // Test of watermark
        let waterMark = CATextLayer.init()
        waterMark.string = "Hassan"
        waterMark.font = CFBridgingRetain("Helvetica-Regular")
        waterMark.fontSize = 17
        waterMark.frame = CGRect(x: (finalTransform?.tx)! + 5.0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height - (finalTransform?.ty)! - 20)
        waterMark.alignmentMode = kCAAlignmentLeft
        waterMark.foregroundColor = UIColor.white.cgColor
        
//        // Draw Rectangle
//        let rectLayer = CAShapeLayer.init()
//        rectLayer.borderColor = UIColor.red.cgColor
//        rectLayer.frame = CGRect(x: (finalTransform?.tx)!, y: (finalTransform?.ty)!, width: (customVideoInfo?.dstSize.width)!, height: (customVideoInfo?.dstSize.height)!)
//        rectLayer.borderWidth = 2.0
        
        let optionalLayer = CALayer.init()
        optionalLayer.addSublayer(textOfVideo)
        optionalLayer.addSublayer(waterMark)
//        optionalLayer.addSublayer(rectLayer)
        optionalLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        optionalLayer.masksToBounds = true
        
        let parentLayer = CALayer.init()
        let videoLayer = CALayer.init()
        parentLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(optionalLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 60)
        videoComposition.renderSize = sizeOfVideo
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        
        //setup timeRange
        let startCMTime = CMTime(seconds: (customVideoInfo?.startTime)!, preferredTimescale: 1000)
        let durationCMTime = CMTime(seconds: (customVideoInfo?.endTime)! - (customVideoInfo?.startTime)!, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startCMTime, duration: durationCMTime)
        
        
        let instruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        instruction.backgroundColor = backgroundColor.cgColor
        
        
        //setup transformation
        let transformer : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: compositionVideoTrack)
        if customVideoInfo?.isFirstAssetPortrait == true {
            finalTransform?.ty = (finalTransform?.ty)! + (customVideoInfo?.scale)! * (customVideoInfo?.naturalSize?.height)!
        }
        transformer.setTransform(finalTransform!, at: kCMTimeZero)
        instruction.layerInstructions = NSArray.init(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray.init(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        
        exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = fileUrl
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange = timeRange
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async(execute: {
                if self.exporter?.status == AVAssetExportSessionStatus.completed {
                    print("process success")
                    let viewController = self.navigationController?.previousViewController() as! ProcessViewController
                    viewController.customVideoInfo?.temporaryVideoURL = fileUrl
                    self.performSegue(withIdentifier: "previewViewController", sender: self)
                    self.timer?.invalidate()
                } else {
                    print("fail \(String(describing: self.exporter?.status)) \(String(describing: self.exporter?.error))")
                    self.timer?.invalidate()
                    self.navigationController?.popViewController(animated: true)
                }
            })
        })
        
    }
    
    func backToProcessViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func catchBackgroundNotification(notification:Notification) {
        if exporter != nil {
            exporter?.cancelExport()
        } else {
            backToProcessViewController()
        }
    }
}
