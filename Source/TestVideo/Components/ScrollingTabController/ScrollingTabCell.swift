//
//  ScrollingTabCell.swift
//  TestVideo
//
//  Created by Clever on 6/6/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit

/**
 * Default tab cell implementation for the tab controller
 */
open class ScrollingTabCell: UICollectionViewCell {
    
    // cell fomarts
    let cellTopPadding: CGFloat = 2
    let cellBorderWidth: CGFloat = 2
    let cellButtonFontSelectedColor = UIColor(rgb: 0x6ED95D)
    let cellButtonFontDefaultColor = UIColor(rgb: 0x111111)
    let cellButtonFont = UIFont(name: "Helvetica Neue", size: 18)

    
    /// Title label shown in the cell.
    open var titleLabel = UILabel()
    
    open var selectionIndicator = UIView()
    
    var selectionIndicatorLeadingConstraint: NSLayoutConstraint!
    var selectionIndicatorBottomConstraint: NSLayoutConstraint!
    var selectionIndicatorHeightConstraint: NSLayoutConstraint!
    var selectionIndicatorWidthConstraint: NSLayoutConstraint!

    /// Specifies the offset of the selection indicator from the bottom of the view. Defaults to 0.
    open var selectionIndicatorOffset: CGFloat = 0 {
        didSet {
            if selectionIndicatorBottomConstraint != nil {
                selectionIndicatorBottomConstraint.constant = selectionIndicatorOffset
            }
        }
    }


    /// Specifies the height of the selection indicator. Defaults to 5.
    open var selectionIndicatorHeight: CGFloat = 10 {
        didSet {
            if selectionIndicatorHeightConstraint != nil {
                selectionIndicatorHeightConstraint.constant = cellBorderWidth
            }
        }
    }

    open var defaultColor: UIColor = .darkText {
        didSet {
            if !isSelected {
                titleLabel.textColor = defaultColor
            }
        }
    }
    
    open var selectedColor: UIColor = .blue {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedColor
            }
        }
    }

    open var font: UIFont?
    
    open var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            self.selectionIndicator.isHidden = isSelected ? false : true
            if isSelected {
                titleLabel.textColor = cellButtonFontSelectedColor
            } else {
                titleLabel.textColor = cellButtonFontDefaultColor
            }
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                titleLabel.textColor = selectedColor
            } else {
                titleLabel.textColor = defaultColor
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
//        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[view]-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: ["view": titleLabel])

        let titleContraints = [
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .lessThanOrEqual,
                                                      toItem: self, attribute: .height, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
//                               toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                               toItem: self, attribute: .top, multiplier: 1, constant: cellTopPadding),
        ]

        titleLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)

        NSLayoutConstraint.activate(horizontalConstraints + titleContraints)
        
//        selectionIndicator = UIView()
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.backgroundColor = cellButtonFontSelectedColor
        selectionIndicator.isHidden = true
        contentView.addSubview(selectionIndicator)
        selectionIndicatorBottomConstraint = NSLayoutConstraint(item: selectionIndicator, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: selectionIndicatorOffset)
        selectionIndicatorLeadingConstraint = NSLayoutConstraint(item: selectionIndicator, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        selectionIndicatorHeightConstraint = NSLayoutConstraint(item: selectionIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cellBorderWidth)
//        selectionIndicatorWidthConstraint = NSLayoutConstraint(item: selectionIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        selectionIndicatorWidthConstraint = NSLayoutConstraint(item: selectionIndicator, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([selectionIndicatorBottomConstraint, selectionIndicatorLeadingConstraint, selectionIndicatorHeightConstraint, selectionIndicatorWidthConstraint])

    }
}
