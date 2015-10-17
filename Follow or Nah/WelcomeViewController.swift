//
//  ViewController.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 10.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit
import Accounts
import Social

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        self.textView.text          = NSLocalizedString("WELCOME_TEXT_VIEW", comment: "TextView at Welcome screen")
        self.textView.font          = UIFont(name: "Helvetica Neue", size: 15)
        self.textView.textAlignment = NSTextAlignment.Center
    }
    
    func openAppSettings(alert: UIAlertAction!) {
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        
        if let url = settingsUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func useAccount(account: ACAccount) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("mainViewSegue", sender: account)
        }
    }
    
    func selectAccount(accounts: [ACAccount]) {
        let actionSheet = UIAlertController(title: NSLocalizedString("SELECT_TWITTER_ACCOUNT", comment: "Select Twitter account prompt's heading"), message: NSLocalizedString("SELECT_TWITTER_ACCOUNT_MESSAGE", comment: "Select Twitter account prompt's message"), preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel, literally"), style: UIAlertActionStyle.Cancel, handler: nil))
        
        for account in accounts {
            actionSheet.addAction(UIAlertAction(title: "@\(account.username)", style: UIAlertActionStyle.Default, handler: { (actionSheet: UIAlertAction!) in self.useAccount(account) }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    
    @IBAction func loginWithTwitter(button: AnyObject) {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                
                if allAccounts.count <= 0 {
                    let alert = UIAlertController(title: NSLocalizedString("NO_TWITTER_ACCOUNTS", comment: "No Twitter accounts prompt's heading"), message: NSLocalizedString("NO_TWITTER_ACCOUNTS_MESSAGE", comment: "No Twitter accounts prompt's message"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ADD_ACCOUNT", comment: "Add Account button"), style: UIAlertActionStyle.Default, handler: self.openAppSettings))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if allAccounts.count == 1 {
                    self.useAccount(allAccounts.first as! ACAccount)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.selectAccount(allAccounts as! [ACAccount])
                    }
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("TWITTER_ACCESS_BLOCKED", comment: "No access to Twitter prompt's heading"), message: NSLocalizedString("TWITTER_ACCESS_BLOCKED_MESSAGE", comment: "No access to Twitter prompt's message"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("GO_TO_SETTINGS", comment: "Go to Settings button"), style: UIAlertActionStyle.Default, handler: self.openAppSettings))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainViewSegue" {
            let mainVC = segue.destinationViewController as! MainViewController
                mainVC.account = (sender as! ACAccount)
        }
    }

}
