//
//  DataTableViewController.swift
//  TestVideo
//
//  Created by Clever on 5/6/17.
//  Copyright © 2017 CleverMobile. All rights reserved.
//

import Foundation
import UIKit

class DataTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dataTableView: UITableView!
    
    var data: [String] = []
    
    override func viewDidLoad() {
        initDataTable()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func initDataTable() {
        for i in 1...5 {
            let str = "Data  " + String(i)
            data.append(str)
        }
        dataTableView.tableFooterView = UIView(frame: .zero)
        dataTableView.delegate = self
        dataTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataTableViewCell") as! DataTableViewCell
        let index = indexPath.row
        cell.selectionStyle = .none
        cell.titleLabel.text = data[index]
        cell.separatorInset.left = cell.titleLabel.frame.origin.x
        return cell
    }
    
    
    
    @IBAction func OnClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
