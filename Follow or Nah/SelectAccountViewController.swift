//
//  SelectAccountViewController.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 10.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit
import Accounts
import Social

class SelectAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var accounts = [ACAccount]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate   = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let account = self.accounts[indexPath.row]
        
        let cell = UITableViewCell()
            cell.textLabel!.text = "@\(account.username)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = self.accounts[indexPath.row]
        
        let navigationVC = self.presentingViewController as! UINavigationController
        let welcomeVC    = navigationVC.viewControllers[0] as! WelcomeViewController
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            welcomeVC.useAccount(account)
        }
    }

}
