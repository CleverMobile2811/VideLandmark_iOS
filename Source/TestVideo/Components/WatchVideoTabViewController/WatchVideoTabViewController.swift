//
//  File.swift
//  TestVideo
//
//  Created by Clever on 5/6/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import Foundation
import UIKit

class WatchVideoTabViewController: UIViewController {
    
    var itemTextLabel = UILabel(frame: CGRect.zero)
    var backgroundColor: UIColor = UIColor.purple
    
    override func viewDidLoad() {
        view.backgroundColor = backgroundColor
        self.view.addSubview(itemTextLabel)
        
        print("Did Load \(itemTextLabel.text)")
        
        self.itemTextLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        self.itemTextLabel.textColor = UIColor.black
        self.itemTextLabel.font = UIFont.systemFont(ofSize: 100)
        self.itemTextLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontal = NSLayoutConstraint(item: itemTextLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let vertical = NSLayoutConstraint(item: itemTextLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([horizontal, vertical])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Will appear \(itemTextLabel.text)")
        usleep(1000)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Did appear \(itemTextLabel.text)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Will disappear \(itemTextLabel.text)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Did disappear \(itemTextLabel.text)")
    }
}
