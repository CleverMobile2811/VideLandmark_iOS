//
//  ModalViewController.swift
//  TestVideo
//
//  Created by Hassan Ahmed on 2017-06-11.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func scrollingTabController(_ tabController: ModalViewController, displayedViewControllerAtIndex: Int)
}


class ModalViewController: UIViewController, ModalViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollingTabController(_ tabController: ModalViewController, displayedViewControllerAtIndex: Int) {
        
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as? ScrollingTabCell else {
            fatalError("Class for tab cells must be a subclass of the scrolling tab cell")
        }
        
        let viewController = viewControllers[(indexPath as NSIndexPath).item]
        cell.title = viewController.tabBarItem.title
        
        return cell
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fontAttributes = [NSFontAttributeName: cellButtonFont]
        let title = viewControllers[indexPath.row].tabBarItem.title! as NSString
        
        var size = title.size(attributes: fontAttributes)
        size.width = size.width + 16
        size.height = cellHeight
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionInsetTop, left: sectionInsetLeft, bottom: sectionInsetBottom, right: sectionInsetRight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        selectTab(atIndex: (indexPath as NSIndexPath).item, animated: true)
    }
    
    // Add Outlets
    @IBOutlet weak var tabControllersView: UIScrollView!
    @IBOutlet weak var tabView: ScrollingTabView!
    
    var createViewController: CreateViewController?

    // UIEdgeInsets
    let sectionInsetTop: CGFloat = 20
    let sectionInsetLeft: CGFloat = 20
    let sectionInsetRight: CGFloat = 20
    let sectionInsetBottom: CGFloat = 20

    // UI tabPadding
    let tabPadding: CGFloat = 0
    
    /// Specifies if the tab view should size the width of the tabs to their content.
    var tabSizing: ScrollingTabView.TabSizing = .fitViewFrameWidth {
        didSet {
            tabView.tabSizing = tabSizing
        }
    }
    
    // cell fomarts
    let cellHeight: CGFloat = 30
    let cellSpacing: CGFloat = 15
    let cellButtonFont = UIFont(name: "Helvetica Neue", size: 18)

    /// The current scrolled percentage
    var scrolledPercentage: CGFloat {
        guard tabControllersView.contentSize.width > 0 else {
            return 0
        }
        
        return self.tabControllersView.contentOffset.x / tabControllersView.contentSize.width
    }

    
    var viewControllers: [UIViewController] = []
    
    let tabSizingMapping: [ScrollingTabView.TabSizing] = [.fitViewFrameWidth, .fixedSize(100), .sizeToContent, .flexibleWidth]
    let tabSize : ScrollingTabView.TabSizing = .fixedSize(100)
    var viewControllerCount = 2
    
    var viewType: String = "1View"
    
    let views: [String] = []
    
    static fileprivate var sizingCell = ScrollingTabCell(frame: CGRect(x: 0, y: 0, width: 9999.0, height: 30.0))

    
    //scrollTabControllers
    var jumpScroll = false
    
    open internal(set) var currentPage: Int = 0
    var previousPage: Int = 0
    var updatingCurrentPage = true
    var loadedPages = (0 ..< 0)
    var numToPreload = 1
    fileprivate var largestTabSize = CGSize.zero
    fileprivate var deferredInitialSelectedPage: Int?
    fileprivate var initialAppearanceComplete = false
    
    var tabControllersViewRightConstraint: NSLayoutConstraint?

    typealias TabItem = (container: UIView, controller: UIViewController)
    var items = [TabItem]()

    
    override func viewDidLoad() {
        initUI()
        initTabView()
        configureViewControllers()
        setLargestTabSize()
        reloadData()
        loadTab(0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedPage = deferredInitialSelectedPage , !initialAppearanceComplete {
            initialAppearanceComplete = true
            selectTab(atIndex: selectedPage, animated: false)
            deferredInitialSelectedPage = nil
        } else {
            reloadCurrentPage(animated: animated)
        }
        
        scrollingTabController(self, displayedViewControllerAtIndex: currentPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialAppearanceComplete {
            childEndAppearanceTransition(currentPage)
        }
        
        initialAppearanceComplete = true
        
        let indexPath = IndexPath(row: 0, section: 0)
        tabView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        childBeginAppearanceTransition(currentPage, isAppearing: false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        childEndAppearanceTransition(currentPage)
    }
    
    func reloadCurrentPage(animated: Bool) {
        childBeginAppearanceTransition(currentPage, isAppearing: true, animated: animated)
        
        let animationBlock = {
            self.tabView.collectionView.collectionViewLayout.invalidateLayout()
            self.tabView.panToPercentage(self.scrolledPercentage)
        }
        
        guard let transitionCoordinator = transitionCoordinator else {
            animationBlock()
            return;
        }
        
        transitionCoordinator.animate(alongsideTransition: { context in
            animationBlock()
        }, completion: nil)
    }
    
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        // In order to send child view controllers the view(Will/Did)(Appear/Disappear) calls at the
        // correct times and only when the view controller is visible, we will fully control the
        // appearance calls.
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnClickDismissBtn(_ sender: UIButton) {
        dissmissViewController()
    }
    
    /**
     Completes an appearance transition of the current page of the scrolling tab bar
     */
    func childEndAppearanceTransition(_ index: Int) {
        guard index >= 0 && index < viewControllers.count else {
            return
        }
        
        let child = viewControllers[index]
        child.endAppearanceTransition()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tabControllersView else {
            return
        }
        
        guard updatingCurrentPage else {
            return
        }
        
        if scrollView.isTracking {
            checkAndLoadPages()
        }
        if jumpScroll == false {
            tabView.panToPercentage(scrolledPercentage)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            checkAndLoadPages()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkAndLoadPages()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        loadedPages = (currentPage ..< currentPage)
        lazyLoad(currentPage)
        jumpScroll = false
        
        childEndAppearanceTransition(currentPage)
        childEndAppearanceTransition(previousPage)
        
        // When scrolling with animation, not all items may be captured in the loadedPages interval.
        // This clears out any remaining views left on the scrollview.
        for index in 0..<items.count {
            unloadTab(index)
        }
    }

    
    func checkAndLoadPages() {
        let width = tabControllersView.bounds.width
        guard width > 0 else {
            return
        }
        
        let page = Int(tabControllersView.contentOffset.x / width)
        if page != currentPage {
            
            // Tell the former current page that it is going to disappear
            childBeginAppearanceTransition(currentPage, isAppearing: false, animated: true)
            childEndAppearanceTransition(currentPage)
            
            currentPage = page
            
            for offset in 0...(numToPreload + 1) {
                lazyLoad(page + offset)
            }
            
            // Tell the new current page that it will appear
            childBeginAppearanceTransition(currentPage, isAppearing: true, animated: true)
            childEndAppearanceTransition(currentPage)
            
            scrollingTabController(self, displayedViewControllerAtIndex: currentPage)
        }
    }

    func setLargestTabSize() {
        largestTabSize = viewControllers.reduce(CGSize.zero) { (largestSize: CGSize, viewController: UIViewController) -> CGSize in
            ModalViewController.sizingCell.title = viewController.tabBarItem.title
            let size = ModalViewController.sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            return size.width > largestSize.width ? size : largestSize
        }
        tabView.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func initTabView() {
        tabView.collectionView.delegate = self
        tabView.collectionView.dataSource = self
        tabView.backgroundColor = UIColor.brown
//        tabView.centerSelectTabs = true
        tabView.translatesAutoresizingMaskIntoConstraints = true

        tabControllersView.showsHorizontalScrollIndicator = false
        tabControllersView.showsVerticalScrollIndicator = false
        automaticallyAdjustsScrollViewInsets = false
        tabControllersView.isPagingEnabled = true
        tabControllersView.translatesAutoresizingMaskIntoConstraints = false


    }

    func reloadData() {
        tabView.collectionView.reloadData()
        if items.count > 0 {
            tabView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }
    
    func configureViewControllers() {
        for item in items {
            let child = item.controller
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
            item.container.removeFromSuperview()
        }
        
        for viewController in viewControllers {
            items.append(TabItem(addTabContainer(), viewController))
        }
    }
    
    func addTabContainer() -> UIView {
        let firstTab = (items.count == 0)
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: tabControllersView, attribute: .height, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: tabControllersView, attribute: .top, multiplier: 1.0, constant: tabPadding)
        let left: NSLayoutConstraint
        if firstTab {
            left = NSLayoutConstraint(item: container, attribute: .left, relatedBy: .equal, toItem: tabControllersView, attribute: .left, multiplier: 1.0, constant: 0.0)
        } else {
            left = NSLayoutConstraint(item: container, attribute: .left, relatedBy: .equal, toItem: items.last!.container, attribute: .right, multiplier: 1.0, constant: 0.0)
        }
        let right = NSLayoutConstraint(item: container, attribute: .right, relatedBy: .equal, toItem: tabControllersView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        if tabControllersViewRightConstraint != nil {
            tabControllersViewRightConstraint!.isActive = false
        }
        tabControllersViewRightConstraint = right
        
        tabControllersView.addSubview(container)
        NSLayoutConstraint.activate([width, height, top, left, right])
        return container
    }
    
    func initUI() {
        viewControllers.removeAll()
        
        switch viewType {
        case "1View":
            setup1ViewControllers()
            break
        case "2View":
            setup2ViewControllers()
            break
        default:
            break
        }
        
    }

    func setup1ViewControllers() {
        
        let tab1ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab1ViewController") as! Tab1ViewController
        tab1ViewController.itemTextLabel.text = "1"
        tab1ViewController.tabBarItem.title = "VIEW 1"
        
        let tab2ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab2ViewController") as! Tab2ViewController
        tab2ViewController.itemTextLabel.text = "2"
        tab2ViewController.tabBarItem.title = "VIEW 2"
        
        let tab3ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab3ViewController") as! Tab3ViewController
        tab3ViewController.itemTextLabel.text = "3"
        tab3ViewController.tabBarItem.title = "VIEW 3"

        let tab4ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab4ViewController") as! Tab4ViewController
        tab4ViewController.itemTextLabel.text = "4"
        tab4ViewController.tabBarItem.title = "VIEW 4"

        viewControllers.append(tab1ViewController)
        viewControllers.append(tab2ViewController)
        viewControllers.append(tab3ViewController)
        viewControllers.append(tab4ViewController)
        viewControllerCount = viewControllers.count
        
    }
    
    func setup2ViewControllers() {
        
        let tab3ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab3ViewController") as! Tab3ViewController
        tab3ViewController.itemTextLabel.text = "3"
        tab3ViewController.tabBarItem.title = "VIEW 3"
        
        let tab4ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab4ViewController") as! Tab4ViewController
        tab4ViewController.itemTextLabel.text = "4"
        tab4ViewController.tabBarItem.title = "VIEW 4"
        
        viewControllers.append(tab3ViewController)
        viewControllers.append(tab4ViewController)
        viewControllerCount = viewControllers.count
    }
    
    func selectTab(atIndex index: Int, animated: Bool = true) {
        guard 0..<viewControllers.count ~= index else {
            return
        }
        
        if !isViewLoaded || !initialAppearanceComplete {
            deferredInitialSelectedPage = index
            return
        }
        
        // Tell the current view it is disappearing, scroll to the new page and tell that view
        // that it did appear
        childBeginAppearanceTransition(currentPage, isAppearing: false, animated: animated)
        previousPage = currentPage
        
        lazyLoad(index)
        childBeginAppearanceTransition(index, isAppearing: true, animated: animated)
        scrollToTab(atIndex: index, animated: animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updatingCurrentPage = false
        
        coordinator.animate(alongsideTransition: { _ in
            switch self.tabSizing {
            case .fitViewFrameWidth:
                self.tabView.calculateItemSizeToFitWidth(size.width)
            default:
                break
            }
            
            //invalidateLayout during rotation so panToPercentage can put the marker in the right place
            self.tabView.collectionView.collectionViewLayout.invalidateLayout()
            
        }, completion: { context in
            self.updatingCurrentPage = true
            self.tabView.panToPercentage(self.scrolledPercentage)
        })
    }
    
    // Internally scroll to a tab at a given index. This only handles the scroll and not management
    // of the child view appearance
    func scrollToTab(atIndex index: Int, animated: Bool = true) {
        let rect = CGRect(x: CGFloat(index) * tabControllersView.bounds.width, y: 0, width: tabControllersView.bounds.width, height: tabControllersView.bounds.height)
        jumpScroll = true
        currentPage = index
        
        tabControllersView.setContentOffset(rect.origin, animated: animated)
        scrollingTabController(self, displayedViewControllerAtIndex: index)
    }
    
    /**
     Begins an appearance transition of the current page of the scrolling tab bar
     */
    func childBeginAppearanceTransition(_ index: Int, isAppearing: Bool, animated: Bool) {
        guard index >= 0 && index < viewControllers.count else {
            return
        }
        
        let child = viewControllers[index]
        child.beginAppearanceTransition(isAppearing, animated: animated)
    }
    
    func lazyLoad(_ index: Int) {
        guard inRange(index) else { return }
        
        if shouldLoadTab(index) {
            loadTab(index)
        } else {
            unloadTab(index)
        }
    }
    
    func loadTab(_ index: Int) {
        guard inRange(index) else { return }
        guard shouldLoadTab(index) else { return }
        guard !loadedPages.contains(index) else { return }
        
        switch index {
        case loadedPages.lowerBound - 1:
            loadedPages = (index ..< loadedPages.upperBound)
        case loadedPages.upperBound:
            loadedPages = (loadedPages.lowerBound ..< index + 1)
        default:
            loadedPages = (index ..< index)
        }
        
        let container = items[index].container
        let child = items[index].controller
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: child.view, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: child.view, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: child.view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: child.view, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        addChildViewController(child)
        container.addSubview(child.view)
        NSLayoutConstraint.activate([width, height, top, left])
        child.didMove(toParentViewController: self)
    }
    
    func unloadTab(_ index: Int) {
        guard inRange(index) else { return }
        guard !shouldLoadTab(index) else { return }
        
        switch index {
        case loadedPages.lowerBound:
            loadedPages = ((index + 1) ..< loadedPages.upperBound)
        case loadedPages.upperBound - 1:
            loadedPages = (loadedPages.lowerBound ..< index)
        default:
            break
        }
        
        let child = items[index].controller
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
    
    func unloadTabs() {
        
    }
    
    func shouldLoadTab(_ index: Int) -> Bool {
        return index >= (currentPage - numToPreload) && index <= (currentPage + numToPreload)
    }
    
    func inRange(_ index: Int) -> Bool {
        return index >= 0 && index < items.count
    }
    
    @IBAction func OnClickYes(_ sender: UIButton) {
        dissmissViewController()
    }
    
    @IBAction func OnClickNo(_ sender: UIButton) {
        dissmissViewController()
    }

    func dissmissViewController() {
        createViewController?.hideWatchVideoScrollView()
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
