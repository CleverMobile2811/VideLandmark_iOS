//
//  File.swift
//  TestVideo
//
//  Created by Clever on 5/6/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import Foundation
import UIKit

class DataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected : Bool {
        didSet {
            self.checkImageView.isHidden = isSelected ? false : true
        }
    }

}
