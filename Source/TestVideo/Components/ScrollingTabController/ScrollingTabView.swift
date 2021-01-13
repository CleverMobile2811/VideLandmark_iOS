//
//  ScrollingTabView.swift
//  TestVideo
//
//  Created by Clever on 6/6/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//


import UIKit

public let ScrollingTabVerticalDividerType = "VerticalDivider"
public let ScrollingTabTitleCell = "TabCell"

/**
 * View that contains the top set of tabs and their containing collection view.
 */
open class ScrollingTabView: UIView {
    
    public enum TabSizing {
        case fitViewFrameWidth
        case fixedSize(CGFloat)
        case sizeToContent
        ///Takes on the attributes of fitViewFrameWidth until the content is too large and then it takes on the attributes of sizeToContent
        case flexibleWidth
    }

    /// Collection view containing the tabs
    open var collectionView: UICollectionView!
    
    /// Collection view layout for the tab view.
    open var scrollingLayout: ScrollingTabViewFlowLayout!
    
    /// Specifies if the tabs should size to fit their content
    open var tabSizing: TabSizing = .fitViewFrameWidth {
        didSet {
            
            let layout = collectionView.collectionViewLayout as? ScrollingTabViewFlowLayout
            
            switch tabSizing {
            case .fitViewFrameWidth:
                calculateItemSizeToFitWidth(frame.width)
                layout?.flexibleWidth = false
                
            case .fixedSize(let width):
                if let layout = layout {
                    layout.itemSize = CGSize(width: width, height: layout.itemSize.height)
                    layout.flexibleWidth = false
                }
                
            case .flexibleWidth:
                layout?.flexibleWidth = true
                
            // Delegate will handle sizing per cell.
            default :
                layout?.flexibleWidth = false
                break
            }
            
            layout?.invalidateLayout()
        }
    }
    
    /// Specifies if the selection of the tabs remains centered.
    open var centerSelectTabs: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// Specifies the cell to use for each tab.
    open var classForCell: AnyClass = ScrollingTabCell.classForCoder() {
        didSet {
            if collectionView != nil {
                collectionView.register(classForCell, forCellWithReuseIdentifier: ScrollingTabTitleCell)
            }
        }
    }
    
    /// Specifies the class to use for the divider in the view.
    open var classForDivider: AnyClass = ScrollingTabDivider.classForCoder() {
        didSet {
            if collectionView != nil {
                collectionView.collectionViewLayout.register(classForDivider, forDecorationViewOfKind: ScrollingTabVerticalDividerType)
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    var lastPercentage: CGFloat = 0.0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override open var bounds: CGRect {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func setup() {
        backgroundColor = UIColor.white
        
        scrollingLayout = ScrollingTabViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: scrollingLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        
        let horizontalContstraints = NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        
        NSLayoutConstraint.activate(horizontalContstraints)
        NSLayoutConstraint.activate(verticalConstraints)
        
        
        collectionView.register(classForCell, forCellWithReuseIdentifier: ScrollingTabTitleCell)
        collectionView.collectionViewLayout.register(classForDivider, forDecorationViewOfKind: ScrollingTabVerticalDividerType)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch tabSizing {
        case .fitViewFrameWidth:
            calculateItemSizeToFitWidth(frame.width)
        default:
            break
        }
        
        if centerSelectTabs {
            let inset = collectionView.frame.width / 2.0 - scrollingLayout.itemSize.width / 2.0
            collectionView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset)
        } else {
            collectionView.contentInset = UIEdgeInsets.zero
        }
    }
    
    open func panToPercentage(_ percentage: CGFloat) {

        lastPercentage = percentage

        let tabCount = collectionView.numberOfItems(inSection: 0)
        let percentageInterval = CGFloat(1.0 / Double(tabCount))
        
        let firstItem = floorf(Float(percentage * CGFloat(tabCount)))
        let secondItem = firstItem + 1

        var firstPath: IndexPath
        var secondPath: IndexPath
        
        if (firstItem < 0)
        {
            firstPath = IndexPath(item: 0, section: 0)
            secondPath = firstPath
        }
        else if (Int(firstItem) >= tabCount) {
            firstPath = IndexPath(item: tabCount - 1, section: 0)
            secondPath = firstPath
        }
        else
        {
            firstPath = IndexPath(item: Int(firstItem), section: 0)
            if (secondItem < 0) {
                secondPath = IndexPath(item: 0, section: 0)
            } else if (Int(secondItem) >= tabCount) {
                secondPath = IndexPath(item: tabCount - 1, section: 0)
            }
            else {
                secondPath = IndexPath(item: Int(secondItem), section: 0)
            }
        }
        
        let shareSecond = percentage + percentageInterval - CGFloat(secondItem) * percentageInterval
        let shareFirst = percentageInterval - shareSecond
        let percentFirst = shareFirst / percentageInterval
        let percentSecond = shareSecond / percentageInterval
        
        let selectIndexPath = percentFirst >= 0.5 ? firstPath : secondPath
        collectionView.selectItem(at: selectIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())

        let attrs1 = collectionView.collectionViewLayout.layoutAttributesForItem(at: firstPath)
        let attrs2 = collectionView.collectionViewLayout.layoutAttributesForItem(at: secondPath)
        
        let firstFrame = attrs1!.frame
        let secondFrame = attrs2!.frame
        
        var x = firstFrame.width * percentSecond + firstFrame.minX
        if firstItem < 0 {
            x -= firstFrame.width
        }

        let width = firstFrame.width * percentFirst + secondFrame.width * percentSecond
                
        let centerSelectOffset = x - (frame.width / 2 - width / 2.0)
        print("centerSelectOffset: \(centerSelectOffset)")
        if centerSelectTabs {
            collectionView.contentOffset = CGPoint(x: centerSelectOffset, y: 0)
        } else if collectionView.contentSize.width > frame.width {
            let collectionViewWidth = collectionView.contentSize.width
            let halfFrame = (frame.width / 2.0)
            let maxOffset = collectionViewWidth - frame.width
            if x < halfFrame {
                collectionView.contentOffset = CGPoint(x: 0, y: 0)
            } else if x < maxOffset {
                collectionView.contentOffset = CGPoint(x: centerSelectOffset, y: 0)
            } else {
                collectionView.contentOffset = CGPoint(x: maxOffset, y: 0)
            }
        }
    }
    
    func calculateItemSizeToFitWidth(_ width: CGFloat) {
        let numberOfItems = collectionView.numberOfItems(inSection:0)
        if numberOfItems > 0, let layout = collectionView.collectionViewLayout as? ScrollingTabViewFlowLayout {
            let calculatedSize = CGSize(width: (width / CGFloat(numberOfItems)),height: layout.itemSize.height)
            if layout.itemSize != calculatedSize {
                layout.itemSize = calculatedSize
                    layout.invalidateLayout()
                    collectionView.layoutIfNeeded()
                }
            panToPercentage(lastPercentage)
        }
    }
}

/**
 * Custom collection view flow layout for the tab view.
 */
open class ScrollingTabViewFlowLayout: UICollectionViewFlowLayout {
    
    /// Specifies the divider spacing from the top of the tab view. Defaults to 10.
    open var topDividerMargin: CGFloat = 10.0
    
    /// Specifies the divider spacing from the bottom of the tab view. Defaults to 10.
    open var bottomDividerMargin: CGFloat = 10.0
    
    /// Specifies the width of the divider view. Defaults to 1.
    open var dividerWidth: CGFloat = 1.0
    
    /// Specifies the color of the divider. Defaults to black.
    open var dividerColor: UIColor = UIColor.black
    
    /// Specifies if the divider is visible. Defaults to false.
    open var showDivider: Bool = false
    
    var flexibleWidth : Bool = false {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        sectionInset = UIEdgeInsets.zero
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
    }
    
    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = layoutAttributesForItem(at: indexPath)
        let dividerAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: ScrollingTabVerticalDividerType, with: indexPath)
        
        if let attributes = attributes, let collectionView = collectionView {
            dividerAttributes.frame = CGRect(x: attributes.frame.maxX,
                y: topDividerMargin,
                width: dividerWidth,
                height: collectionView.frame.height - topDividerMargin - bottomDividerMargin)
        }
        
        dividerAttributes.zIndex = -1
        
        return dividerAttributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var updatedAttributes = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        if showDivider {
            for layoutAttribute in attributes where layoutAttribute.representedElementCategory == .cell {
                if let dividerAttribute = layoutAttributesForDecorationView(ofKind: ScrollingTabVerticalDividerType, at: layoutAttribute.indexPath) {
                    updatedAttributes.append(dividerAttribute)
                }
            }
        }
        
        return updatedAttributes
    }
}

open class ScrollingTabDivider: UICollectionReusableView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.black
    }
}

