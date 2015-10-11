//
//  EndCreditsViewController.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 11.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit
import Accounts
import Social

class EndCreditsViewController: UIViewController {
    
    @IBOutlet weak var textView  : UITextView!
    @IBOutlet weak var buyButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentMonth = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: NSDate()).month
        
        if 5...7 ~= currentMonth {
            self.textView.text          = replaceNickWithRick(self.textView.text!)
            // Text's style seems to be broken after changing content. Workaround
            self.textView.font          = UIFont(name: "Helvetica Neue", size: 17)
            self.textView.textAlignment = NSTextAlignment.Center
            
            self.buyButton.setTitle(replaceNickWithRick(self.buyButton.titleLabel!.text!), forState: .Normal)
        }
    }
    
    func replaceNickWithRick(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString("Nick", withString: "Rick", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func followWithAccount(account: ACAccount) {
        print("Following @yurijmi with \(account)")
    }
    
    func selectAccountAndFollow(accounts: [ACAccount]) {
        print("Multiple accounts: \(accounts)")
    }
    
    @IBAction func followTapped(button: UIButton) {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let allAccounts = account.accountsWithAccountType(accountType)
                
                dispatch_async(dispatch_get_main_queue()) {
                    if allAccounts.count == 1 {
                        self.followWithAccount(allAccounts.first as! ACAccount)
                    } else {
                        self.selectAccountAndFollow(allAccounts as! [ACAccount])
                    }
                }
            }
        }
    }
    
    @IBAction func starTapped(button: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/yurijmi/Follow-or-Nah")!)
    }
    
    @IBAction func buyTapped(button: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udemy.com/ios-9-swift-2-xcode-7-make-an-app-programming-code-ios9-dev")!)
    }
    
}
