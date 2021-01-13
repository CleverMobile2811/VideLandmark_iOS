//
//  PreviewViewController.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Foundation
import Photos
import MBProgressHUD

class PreviewViewController : UIViewController {
    @IBOutlet weak var selectedBackgroundView: UIView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var viewVideo: UIView!
    
    var temporaryURL : URL?
    var videoPlayer : AVPlayer?
    var audioPlayer : AVQueuePlayer?
    var videoPlayerViewController : AVPlayerViewController?
    var buttonNext : UIBarButtonItem!


    override func viewDidAppear(_ animated: Bool) {
        if (temporaryURL != nil) {
            movieSetup()
        }
        for vc in (self.navigationController?.viewControllers)! {
            if vc is ProgressViewController {
                self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.index(of: vc))!)
                break
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
    @IBAction func OnClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnClickDownload(_ sender: UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        if (temporaryURL != nil) {
            DispatchQueue.main.async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.temporaryURL!)
                }, completionHandler: { (success, err) in
                    if success == true {
                        print("export video success！")
                        //try? FileManager.default.removeItem(at: self.temporaryURL!)
                        
                    } else {
                        print("export video fail！ \(String(describing: err)) \(String(describing: err?.localizedDescription))")
                    }
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                    }
                })
            })
        } else {
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
        
    }
    
    @IBAction func OnVideoPlay(_ sender: UIButton) {
        if (videoPlayer != nil) {
            buttonPlay.isHidden = true
            videoPlayer?.play()
            videoPlayerViewController?.showsPlaybackControls = true;
        }
    }
    
    func movieSetup() {
        videoPlayerViewController = AVPlayerViewController()
        videoPlayer = AVPlayer(url: temporaryURL!)
        videoPlayerViewController?.player = videoPlayer;
        
        self.addChildViewController(videoPlayerViewController!)
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = self.viewVideo.bounds
        viewVideo.layer.addSublayer(playerLayer)
        
        videoPlayerViewController?.view.frame = self.viewVideo.frame
        viewVideo.addSubview((videoPlayerViewController?.view)!)
        
        videoPlayerViewController?.showsPlaybackControls = false
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
    }
    
    func moviePlayerDidFinish(notificaion : NSNotification) -> Void{
        videoPlayer?.seek(to: CMTimeMake(0, 1))
        videoPlayerViewController?.showsPlaybackControls = false;
        buttonPlay.isHidden = false
    }
    
}
