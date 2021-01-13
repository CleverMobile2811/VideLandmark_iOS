//
//  FSAlbumViewCell.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import Photos

final class FSAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkView: UIImageView!
    
    var image: UIImage? {
        
        didSet {
            self.imageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSelected = false
        self.checkView.isHidden = true
    }
    
    override var isSelected : Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.white.cgColor
            self.layer.borderWidth = isSelected ? 2 : 2
            self.checkView.isHidden = isSelected ? false : true
        }
    }
}
