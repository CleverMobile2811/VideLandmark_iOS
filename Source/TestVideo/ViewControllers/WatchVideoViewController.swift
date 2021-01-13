//
//  PreviewViewController.swift
//  TestVideo
//
//  Created by Clever on 22/5/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD
//import WillowTreeScrollingTabController


class WatchVideoViewController : UIViewController, ScrollingTabControllerDelegate {
    func scrollingTabController(_ tabController: ScrollingTabController, displayedViewControllerAtIndex: Int) {
        
    }
    
    @IBOutlet weak var scrollContainer: UIView!

    var scrollTab = ScrollingTabController()
    var viewControllers: [UIViewController] = []
    
    let tabSizingMapping: [ScrollingTabView.TabSizing] = [.fitViewFrameWidth, .fixedSize(100), .sizeToContent, .flexibleWidth]
    let tabSize : ScrollingTabView.TabSizing = .fixedSize(100)
    var viewControllerCount = 2

    var buttonSent: String = "button1"
    
    let views: [String] = []

    override func viewDidLoad() {
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func initUI() {
        viewControllers.removeAll()
        
        switch buttonSent {
        case "button1":
            setup1ViewControllers()
            break
        case "button2":
            setup2ViewControllers()
            break
        default:
            break
        }
        
        setupScrollTab()
    }
    
    func setup1ViewControllers() {
        
        let tab1ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab1ViewController") as! Tab1ViewController
        tab1ViewController.itemTextLabel.text = "1"
        tab1ViewController.tabBarItem.title = "VIEW 1"
        
        let tab2ViewController = self.storyboard?.instantiateViewController(withIdentifier: "tab2ViewController") as! Tab2ViewController
        tab2ViewController.itemTextLabel.text = "2"
        tab2ViewController.tabBarItem.title = "VIEW 2"
        
        
        viewControllers.append(tab1ViewController)
        viewControllers.append(tab2ViewController)
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

    func setupScrollTab() {
        scrollTab.delegate = self
        scrollTab.willMove(toParentViewController: self)
        addChildViewController(scrollTab)
        scrollTab.viewControllers = viewControllers
        scrollTab.view.translatesAutoresizingMaskIntoConstraints = false
        scrollContainer.addSubview(scrollTab.view)
        scrollContainer.layoutIfNeeded()
        
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": scrollTab.view])
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": scrollTab.view])
        NSLayoutConstraint.activate(horizontal + vertical)
        
        scrollTab.didMove(toParentViewController: self)
        scrollTab.tabSizing = tabSize
//        scrollTab.centerSelectTabs = true
   }
    
    @IBAction func OnClickYes(_ sender: UIButton) {
        let vc = self.parent as! CreateViewController
        vc.hideWatchVideoScrollView()
    }
    
    @IBAction func OnClickNo(_ sender: UIButton) {
        let vc = self.parent as! CreateViewController
        vc.hideWatchVideoScrollView()
    }
    
    //
    @IBAction func OnClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
