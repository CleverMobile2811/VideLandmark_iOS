//
//  File.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

import SnapKit

class ProcessViewController : UIViewController, UITextViewDelegate {

    @IBOutlet weak var blackCanvasView: UIView!

    var selectedImageView = UIImageView()
    var selectedBackgroundView = UIView()
    var subtitleTextView = UITextView()
    var keyboardFlag = 0

    var temporaryVideoURL : URL?
    var selectedImage : UIImage?
    var buttonNext : UIBarButtonItem!
    var renderSize : CGSize?
    var finalTransform : CGAffineTransform?
    var numberLine = 0
    var customVideoInfo : CustomVideoInfo?
    var isFirstAssetPortrait = false
    
    var displayX: CGFloat = 0
    var displayY: CGFloat = 0
    var aspectRatio: CGFloat = 16/9
    var displayWidth: CGFloat = 0
    var displayHeight: CGFloat = 0
    
    let backgroundColor = UIColor(rgb: 0x888888)

    
    
    override func viewDidAppear(_ animated: Bool) {
        initKeyboardAccessoryUI()
    }
    
    override func viewDidLoad() {
        initUI()
        initImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
        case "previewViewController":
            let destVC                  = segue.destination as! PreviewViewController
            destVC.temporaryURL         = customVideoInfo?.temporaryVideoURL
            break
        case "progressViewController":
            let destVC                  = segue.destination as! ProgressViewController
            destVC.customVideoInfo      = customVideoInfo
            destVC.renderSize           = renderSize
            destVC.finalTransform       = finalTransform
            destVC.subTitleString       = subtitleTextView.text
            destVC.numberLine           = numberLine
            break
        default:
            break
        }
    }
    
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func OnClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func OnClickNextBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "previewViewController", sender: self)
    }
    @IBAction func OnClickProcessVideo(_ sender: UIButton) {
        if (customVideoInfo?.videoURL != nil) {
            processingVideo()
        }
    }
    
    @IBAction func OnClickDesign1(_ sender: UIButton) {
        let width = self.view.frame.width
        aspectRatio = 16/9
        displayX = 0
        displayY = width * (1 - 1/aspectRatio) / 2
        displayWidth = width
        displayHeight = displayWidth / aspectRatio
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        self.selectedBackgroundView.frame = frame
        initImage()
    }
    
    @IBAction func OnClickDesign2(_ sender: UIButton) {
        let width = self.view.frame.width
        aspectRatio = 1/1
        displayX = 50
        displayWidth = width - displayX * 2
        displayHeight = displayWidth / aspectRatio
        displayY = width - displayHeight
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        self.selectedBackgroundView.frame = frame
        initImage()
    }

    @IBAction func OnClickDesign3(_ sender: UIButton) {
        let width = self.view.frame.width
        aspectRatio = 9/16
        displayX = 103
        displayY = 0
        displayWidth = width - displayX * 2
        displayHeight = displayWidth / aspectRatio
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        self.selectedBackgroundView.frame = frame
        initImage()
    }

    @IBAction func OnClickDesign4(_ sender: UIButton) {
        let width = self.view.frame.width
        aspectRatio = 9/16
        displayX = 20
        displayY = 37.5
        displayHeight = width - 75
        displayWidth = displayHeight * aspectRatio
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        self.selectedBackgroundView.frame = frame
        initImage()
    }

    @IBAction func OnClickDesign5(_ sender: UIButton) {
        let width = self.view.frame.width
        aspectRatio = 4/3
        displayX = 25
        displayY = 25
        displayWidth = width - 50
        displayHeight = displayWidth / aspectRatio
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        self.selectedBackgroundView.frame = frame
        initImage()
    }

    func singleTappedOnSubtitle() {
        print("--OnSingleTouchDownTopText")
        subtitleTextView.layer.borderColor = UIColor.white.cgColor
        if (subtitleTextView.isEditable == true) {
            subtitleTextView.becomeFirstResponder()
        } else {
            subtitleTextView.isEditable = true
        }
        self.view.endEditing(true)
        
    }
    
    func doubleTappedOnSubtitle() {
        subtitleTextView.layer.borderColor = UIColor.white.cgColor
        subtitleTextView.isEditable = true
    }
    
    func handleTap(sender: UIGestureRecognizer) {
        let position = sender.location(in: self.subtitleTextView)
        print(position)
        subtitleTextView.isEditable = false
        subtitleTextView.layer.borderColor = UIColor.clear.cgColor
    }
    // init Selected ImageView
    func initUI() {
        let width = self.view.frame.width
        aspectRatio = 16/9
        displayX = 0
        displayY = width * (1 - 1/aspectRatio) / 2
        displayWidth = width
        displayHeight = width / aspectRatio
        
        let frame = CGRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight)
        selectedBackgroundView = UIView.init(frame: frame)
        blackCanvasView.addSubview(selectedBackgroundView)
        blackCanvasView.backgroundColor = backgroundColor
        selectedBackgroundView.backgroundColor = backgroundColor
        selectedImageView.backgroundColor = backgroundColor
        selectedBackgroundView.addSubview(selectedImageView)
        blackCanvasView.addSubview(subtitleTextView)
        subtitleTextView.delegate = self
        subtitleTextView.layer.borderColor = UIColor.clear.cgColor
        subtitleTextView.layer.backgroundColor = UIColor.clear.cgColor
        subtitleTextView.textColor = UIColor.white
        subtitleTextView.layer.borderWidth = 2.0
        subtitleTextView.font = UIFont(name: "Helvetica-Regular", size: 16)
        subtitleTextView.textAlignment = .center
        subtitleTextView.maximumZoomScale = 100
        subtitleTextView.isEditable = false
        subtitleTextView.snp.makeConstraints{(make) -> Void in
            make.width.equalTo(blackCanvasView)
            make.height.equalTo(82)
            make.left.top.right.equalTo(0)
        }
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedOnSubtitle))
        doubleTap.numberOfTapsRequired = 2
        subtitleTextView.addGestureRecognizer(doubleTap)
        let signleTap = UITapGestureRecognizer(target: self, action: #selector(singleTappedOnSubtitle))
        signleTap.numberOfTapsRequired = 1
        subtitleTextView.addGestureRecognizer(signleTap)
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapHandler)
//        initKeyboardAccessoryUI()
    }
    
    func initKeyboardAccessoryUI() {
        print("\(blackCanvasView.frame.size.width)")
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0,width: blackCanvasView.frame.size.width, height: 60))
        accessoryView.backgroundColor = UIColor.white
        let doneBtn = UIButton(frame: CGRect(x: blackCanvasView.frame.size.width - 70, y: 0, width: 50, height: 60))
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.backgroundColor = UIColor.white
        doneBtn.titleLabel!.font = UIFont(name: "Arial", size: 18)
        doneBtn.setTitleColor(UIColor.green, for: .normal)
        doneBtn.addTarget(self, action: #selector(executeDone), for: .touchUpInside)
        accessoryView.addSubview(doneBtn)
        subtitleTextView.inputAccessoryView = accessoryView
    }
    func initImage() {
        if (customVideoInfo?.sourceImage != nil) {
            changeImage((customVideoInfo?.sourceImage)!)
        }
    }
    
    
    func changeImage(_ asset: UIImage) {
        self.selectedImageView.image = ImageViewUtil.imageWithImage(sourceImage: (customVideoInfo?.sourceImage)!, selectedImageView: self.selectedImageView, selectedBackgroundView: self.selectedBackgroundView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.centerVertically()
        return true
    }
    
    // process video into temporary directory
    func processingVideo() {
        let asset : AVAsset = AVAsset(url: (customVideoInfo?.videoURL)!)
        let clipVideoTrack : [AVAssetTrack] = asset.tracks(withMediaType: AVMediaTypeVideo)
        var originalSize : CGSize = clipVideoTrack[0].naturalSize
        let firstTransform = clipVideoTrack[0].preferredTransform
        if firstTransform.a == 0 && firstTransform.b == 1.00 && firstTransform.c == -1.00 && firstTransform.d == 0 {
            isFirstAssetPortrait = true
        }
        if firstTransform.a == 0 && firstTransform.b == -1.00 && firstTransform.c == 1.00 && firstTransform.d == 0 {
            isFirstAssetPortrait = true
        }
        if isFirstAssetPortrait == true {
            let tempHeight = originalSize.width
            originalSize.width = originalSize.height
            originalSize.height = tempHeight
        }
        
        // MAKE THIS DYNAMIC
        
        var frameWidth : CGFloat = 400
        var frameHeight : CGFloat = 400
        if originalSize.width >= 400 && originalSize.width < 640 {
            frameWidth = CGFloat(400)
            frameHeight = CGFloat(400)
        } else if originalSize.width >= 640 && originalSize.width < 800 {
            frameWidth = CGFloat(640)
            frameHeight = CGFloat(640)
        } else if originalSize.width >= 800 {
            frameWidth = CGFloat(800)
            frameHeight = CGFloat(800)
        }
        let width = self.view.frame.width
        let exportRatio: CGFloat = width / frameWidth
        let tx : CGFloat = (displayX + selectedImageView.frame.origin.x) / exportRatio
        let ty : CGFloat = (displayY + selectedImageView.frame.origin.y) / exportRatio
        
        renderSize = CGSize(width: frameWidth, height: frameHeight)
        let scaleX  = (selectedImageView.frame.width * (frameWidth/width)) / originalSize.width
        let scaleY  = (selectedImageView.frame.height * (frameWidth/width)) / originalSize.height
        print("(\(tx), \(ty)), \(frameWidth), \(scaleX), \(scaleY), viewWidth=\(width), exportRatio=\(exportRatio)")
        
        finalTransform = clipVideoTrack[0].preferredTransform.scaledBy(x: scaleX, y: scaleY)
        finalTransform?.tx = tx
        finalTransform?.ty = ty
    
        numberLine = subtitleTextView.numberOfLines()
        
        customVideoInfo?.naturalSize = originalSize
        customVideoInfo?.dstSize.width = originalSize.width * scaleX
        customVideoInfo?.dstSize.height = originalSize.height * scaleY
        customVideoInfo?.isFirstAssetPortrait = isFirstAssetPortrait
        customVideoInfo?.scale = scaleX
        self.performSegue(withIdentifier: "progressViewController", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func executeDone() {
        subtitleTextView.centerVertically()
        subtitleTextView.isEditable = false
        subtitleTextView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        textView.centerVertically()
        subtitleTextView.isEditable = false
        subtitleTextView.layer.borderColor = UIColor.clear.cgColor
    }
}
