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
    
    @IBAction func loginWithTwitter(button: AnyObject) {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                
                if allAccounts.count <= 0 {
                    let alert = UIAlertController(title: "No Twitter accounts found", message: "It seems that you don't have any Twitter accounts connected to your iPhone. Go to Twitter Settings and add your account there.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Add account", style: UIAlertActionStyle.Default, handler: self.openAppSettings))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if allAccounts.count == 1 {
                    self.useAccount(allAccounts.first as! ACAccount)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("selectAccountSegue", sender: allAccounts)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Access to Twitter is blocked", message: "It seems that you disabled access to Twitter. Go to Twitter Settings and enable access for \"Follow or Nah\".", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Go to Settings", style: UIAlertActionStyle.Default, handler: self.openAppSettings))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectAccountSegue" {
            let selectAccountVC = segue.destinationViewController as! SelectAccountViewController
                selectAccountVC.accounts = sender as! [ACAccount]
        }
        if segue.identifier == "mainViewSegue" {
            let mainVC = segue.destinationViewController as! MainViewController
                mainVC.account = (sender as! ACAccount)
        }
    }

}
