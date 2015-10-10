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
                    print("No Twitter accounts found")
                } else if allAccounts.count == 1 {
                    print("Twitter account found")
                } else {
                    print("Multiple Twitter accounts found")
                }
            } else {
                print("Access wasn't granted")
            }
        }
    
    }

}
