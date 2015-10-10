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

class ViewController: UIViewController {
    
    @IBAction func loginWithTwitter(button: AnyObject) {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                
                if allAccounts.count <= 0 {
                    let settingsAction = UIAlertAction(title: "Add account", style: .Default) { (_) -> Void in
                        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                        
                        if let url = settingsUrl {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                    
                    let alert = UIAlertController(title: "No Twitter accounts found", message: "It seems that you don't have any Twitter accounts connected to your iPhone. Go to Twitter Settings and add your account there.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(settingsAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if allAccounts.count == 1 {
                    print("Twitter account found")
                } else {
                    print("Multiple Twitter accounts found")
                }
            } else {
                let settingsAction = UIAlertAction(title: "Go to Settings", style: .Default) { (_) -> Void in
                    let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                    
                    if let url = settingsUrl {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                
                let alert = UIAlertController(title: "Access to Twitter is blocked", message: "It seems that you disabled access to Twitter. Go to Twitter Settings and enable access for \"Follow or Nah\".", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(settingsAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    
    }

}
