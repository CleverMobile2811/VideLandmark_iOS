//
//  File.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import MBProgressHUD

class CreateViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var watchScrollView: UIView!
    @IBOutlet weak var hideWatchScrollViewBtn: UIButton!
    let imagePicker : UIImagePickerController = UIImagePickerController();
    var videoURLArray = [URL]()
    var callCnt = 0
    var viewType: String = "1View"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
        case "videosViewController":
            let destVC              = segue.destination as! VideosViewController
            destVC.videoURLArray    = self.videoURLArray
            break
        case "watchVideoViewController":
            let destVC              = segue.destination as! WatchVideoViewController
            destVC.buttonSent    = "button1"
            break;
        case "dataTableViewController":
            break;
        case "modalViewController":
            let destVC                      = segue.destination as! ModalViewController
            destVC.viewType                 = viewType
            destVC.modalPresentationStyle   = .overCurrentContext
            destVC.createViewController     = self
            break;
        default:
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func OnClick1ViewBtn(_ sender: UIButton) {
        viewType = "1View"
        showWatchVideoScrollView()
        performSegue(withIdentifier: "modalViewController", sender: self)
    }

    @IBAction func OnClick2ViewBtn(_ sender: UIButton) {
        viewType = "2View"
        showWatchVideoScrollView()
        performSegue(withIdentifier: "modalViewController", sender: self)
    }
    
    @IBAction func OnClickDataBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "dataTableViewController", sender: self)
    }
    
    @IBAction func OnClickHideWatchScrollView(_ sender: UIButton) {
        hideWatchVideoScrollView()
    }
    
    @IBAction func OnClickCreateVideo(_ sender: UIButton) {
        gotoCameraRoll()
    }
    
    func showWatchVideoScrollView() {
        UIView.animate(withDuration: 1, delay:0.2, animations: {
            self.backgroundView.frame.origin.y = self.backgroundView.frame.origin.y - 100
        }, completion: nil)
    }
    
    func hideWatchVideoScrollView() {
        UIView.animate(withDuration: 1, delay:0.2, animations: {
            self.backgroundView.frame.origin.y = self.backgroundView.frame.origin.y + 100
        }, completion: nil)
    }
    
    //#MARK: galary related
    func gotoCameraRoll(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            let allVidOptions = PHFetchOptions()
            allVidOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            self.videoURLArray.removeAll()
            let allVids = PHAsset.fetchAssets(with: allVidOptions)
            self.callCnt = allVids.count
            if (self.callCnt != 0) {
                for index in 0..<allVids.count {
                    //fetch Asset here
                    DispatchQueue.global(qos: .default).async(execute: {
                        let options: PHVideoRequestOptions = PHVideoRequestOptions()
                        options.version = .original
                        PHImageManager.default().requestAVAsset(forVideo: allVids[index], options: options, resultHandler: {
                            (avAsset, audioMix, infoArray) in
                            DispatchQueue.main.async {
                                if let urlAsset = avAsset as? AVURLAsset {
                                    let localVideoUrl = urlAsset.url
                                    self.videoURLArray.append(localVideoUrl)
                                    self.callCnt = self.callCnt - 1
                                    if (self.callCnt == 0) {
                                        hud.hide(animated: true)
                                        self.performSegue(withIdentifier: "videosViewController", sender: self)
                                    }
                                }
                            }
                        })
                    })
                }
            } else {
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.performSegue(withIdentifier: "videosViewController", sender: self)
                }
            }
            
        }
    }
}
