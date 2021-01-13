//
//  File.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import Photos
import ABVideoRangeSlider


class VideosViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ABVideoRangeSliderDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blackCanvasView: UIView!
    @IBOutlet weak var videoRangeSlider: ABVideoRangeSlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var periodTimeLabel: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var whiteBarView: UIView!
    
    var videoURLArray = [URL]()
    var imageArray = [UIImage]()
    var buttonNext : UIBarButtonItem!
    var selectedIndex = -1
    var finalIndex = -1
    var selectedImageView = UIImageView()
    var selectedBackgroundView = UIView()
    
    var customVideoInfoArray = [CustomVideoInfo]()
    var customVideoInfo : CustomVideoInfo?
    
    override func viewDidLoad() {
        initUI()
        initVideoRangeSlider()
        loadTemporaryVideos()
        initImageArray()
        initFormatCollectionView()
        self.selectedBackgroundView.backgroundColor = UIColor(red: 0x80, green: 0x80, blue: 0x80)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let screenWidth = collectionView.frame.width - 2
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        collectionView!.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
        case "processViewController":
            let destVC              = segue.destination as! ProcessViewController
            destVC.customVideoInfo  = customVideoInfoArray[finalIndex]
            break
        default:
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //
    @IBAction func OnClickBackBtn(_ sender: UIButton) {        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnClickNextBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "processViewController", sender: self)
    }
    
    @IBAction func OnClickSelectBtn(_ sender: Any) {
        let duration = ((customVideoInfo?.endTime)! - (customVideoInfo?.startTime)!)
        if (duration > 120) {
            self.alert(message: "Only 2 minutes videos are alllowed")
            customVideoInfo?.endTime = (customVideoInfo?.startTime)! + 120
            showRange()
            videoRangeSlider.setEndPosition(seconds: Float((customVideoInfo?.endTime)!))
        } else {
            finalIndex = selectedIndex
            changeImage(customVideoInfoArray[selectedIndex].sourceImage!)
            UIView.animate(withDuration: 1, delay:0.5, animations: {
                self.editView.frame.origin.y = self.editView.frame.origin.y + self.editView.frame.height
                self.blackCanvasView.frame.origin.y = self.blackCanvasView.frame.origin.y + 60
                self.collectionView.frame.origin.y = self.collectionView.frame.origin.y + 60
            }, completion: {completion in
                self.navigationView.viewWithTag(2)?.isHidden = false
            })
        }
        
    }
    
    @IBAction func OnClickCancelBtn(_ sender: UIButton) {
        if selectedIndex >= 0 {
            collectionView.deselectItem(at: IndexPath(item: selectedIndex, section: 0), animated: true)
        }
        if finalIndex < 0 {
            selectedImageView.image = nil
            selectedImageView.backgroundColor = UIColor(red: 0x80, green: 0x80, blue: 0x80)
        } else {
            changeImage(customVideoInfoArray[finalIndex].sourceImage!)
            collectionView.selectItem(at: IndexPath(item: finalIndex, section: 0), animated: true, scrollPosition: .centeredVertically)
        }
        UIView.animate(withDuration: 1, delay:0.5, animations: {
            self.editView.frame.origin.y = self.editView.frame.origin.y + self.editView.frame.height
            self.blackCanvasView.frame.origin.y = self.blackCanvasView.frame.origin.y + 60
            self.collectionView.frame.origin.y = self.collectionView.frame.origin.y + 60
        }, completion: {completion in
        })
    }
    
    // init Selected ImageView
    func initUI() {
        let width = self.view.frame.width
        let frame = CGRect(x: 0, y: width * (3.6 / 16.0), width: width, height: width * (9.0 / 16.0))
        selectedBackgroundView = UIView.init(frame: frame)
        blackCanvasView.addSubview(selectedBackgroundView)
        selectedBackgroundView.addSubview(selectedImageView)
        navigationView.viewWithTag(2)?.isHidden = true
        editView.isHidden = true
        videoRangeSlider.delegate = self
    }
    
    // set format collectionView
    func initFormatCollectionView() {
        collectionView.register(UINib(nibName: "FSAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "FSAlbumViewCell")
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
//        let screenWidth = collectionView.frame.width - 2
//        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        collectionView!.collectionViewLayout = layout
//        collectionView!.reloadData()
    }
    
    // load Temporary VideoURLs from UserDefault
    func loadTemporaryVideos() {
    }
    
    // generate thumbnails from url
    func initImageArray() {
        for assetURL in videoURLArray {
            let customVideoInfo = CustomVideoInfo()
            let image = ImageViewUtil.generateThumnail(customVideoInfo: customVideoInfo, url: assetURL as URL, fromTime: 0)
            customVideoInfo.videoURL = assetURL
            customVideoInfo.sourceImage = image
            print("--size=%@", image?.size)
            customVideoInfoArray.append(customVideoInfo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customVideoInfoArray.count
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell", for: indexPath) as! FSAlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        cell.image = self.customVideoInfoArray[(indexPath as NSIndexPath).item].sourceImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        changeImage(customVideoInfoArray[selectedIndex].sourceImage!)
        customVideoInfo = customVideoInfoArray[selectedIndex]
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        showEditView()
    }
    
    func showEditView() {
        UIView.animate(withDuration: 1, delay:0.5, animations: {
            //top
            self.editView.isHidden = false
            self.editView.frame.origin.y = self.editView.frame.origin.y - self.editView.frame.height
            self.blackCanvasView.frame.origin.y = self.blackCanvasView.frame.origin.y - 60
            self.collectionView.frame.origin.y = self.collectionView.frame.origin.y - 60
        }, completion: {completion in
            self.showVideoRangeSlider()
        })
    }
    
    func initVideoRangeSlider() {
        videoRangeSlider.delegate = self
        videoRangeSlider.minSpace = 1.0
        /* Uncomment to customize the Video Range Slider */
        
        let customStartIndicator =  UIImage(named: "CustomStartIndicator")
        videoRangeSlider.setStartIndicatorImage(image: customStartIndicator!)
        
        let customEndIndicator =  UIImage(named: "CustomEndIndicator")
        videoRangeSlider.setEndIndicatorImage(image: customEndIndicator!)
        
        let customBorder =  UIImage(named: "CustomBorder")
        videoRangeSlider.setBorderImage(image: customBorder!)
        
        let customProgressIndicator =  UIImage(named: "CustomProgress")
        videoRangeSlider.setProgressIndicatorImage(image: customProgressIndicator!)
        
        // Customize starTimeView
        let customView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 60,
                                              height: 40))
        customView.backgroundColor = .black
        customView.alpha = 0.5
        customView.layer.borderColor = UIColor.black.cgColor
        customView.layer.borderWidth = 1.0
        customView.layer.cornerRadius = 8.0
        videoRangeSlider.startTimeView.backgroundView = customView
        videoRangeSlider.startTimeView.marginLeft = 2.0
        videoRangeSlider.startTimeView.marginRight = 2.0
        videoRangeSlider.startTimeView.timeLabel.textColor = .white
        videoRangeSlider.hideProgressIndicator()
        videoRangeSlider.startTimeView.isHidden = true
        videoRangeSlider.endTimeView.isHidden = true
    }
    
    func showVideoRangeSlider() {
        videoRangeSlider.setVideoURL(videoURL: (customVideoInfo?.videoURL)!)
        // Set initial position of Start Indicator
        videoRangeSlider.setStartPosition(seconds: 0)
        
        if (customVideoInfo?.range)! >= Float64(120) {
            customVideoInfo?.endTime = 120
        } else {
            customVideoInfo?.endTime = (customVideoInfo?.range)!
        }
        showRange()
        // Set initial position of End Indicator
        videoRangeSlider.setEndPosition(seconds: Float((customVideoInfo?.endTime)!))
    }
    
    func showRange() {
        let startMin = Int((customVideoInfo?.startTime)!) / 60
        let startSec = Int((customVideoInfo?.startTime)!) % 60
        let endMin = Int((customVideoInfo?.endTime)!) / 60
        let endSec = Int((customVideoInfo?.endTime)!) % 60
        periodTimeLabel.text = "\(startMin):\(startSec) to \(endMin):\(endSec)"
        let periodMin = Int((customVideoInfo?.endTime)! - (customVideoInfo?.startTime)!) / 60
        let periodSec = Int((customVideoInfo?.endTime)! - (customVideoInfo?.startTime)!) % 60
        durationTimeLabel.text = "\(periodMin):\(periodSec)"
    }

    func changeImage(_ asset: UIImage) {
        selectedImageView.backgroundColor = UIColor(red: 0x09, green: 0x09, blue: 0x09)
        selectedImageView.image = ImageViewUtil.globalImageWithImage(sourceImage: asset, selectedImageView: selectedImageView, selectedBackgroundView: self.selectedBackgroundView)
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        
    }
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        customVideoInfo?.startTime = startTime
        customVideoInfo?.endTime = endTime
        showRange()
    }
}
