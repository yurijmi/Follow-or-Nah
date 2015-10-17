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
    
    @IBOutlet weak var headingLabel : UILabel!
    @IBOutlet weak var textView     : UITextView!
    @IBOutlet weak var buyButton    : UIButton!
    
    var noFriends : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if noFriends {
            self.headingLabel.text = NSLocalizedString("END_CREDITS_NO_FRIENDS_LABEL", comment: "Label at End Credits screen if user don't follow anyone")
            self.textView.text     = NSLocalizedString("END_CREDITS_NO_FRIENDS_TEXT_VIEW", comment: "TextView at End Credits screen if user don't follow anyone")
        } else {
            self.textView.text = NSLocalizedString("END_CREDITS_TEXT_VIEW", comment: "TextView at End Credits screen")
        }
        
        let currentMonth = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: NSDate()).month
        
        if 5...7 ~= currentMonth {
            self.textView.text = replaceNickWithRick(self.textView.text!)
            
            self.buyButton.setTitle(replaceNickWithRick(self.buyButton.titleLabel!.text!), forState: .Normal)
        }
        
        // Text's style seems to be broken after changing content. Workaround
        self.textView.font          = UIFont(name: "Helvetica Neue", size: 17)
        self.textView.textAlignment = NSTextAlignment.Center
    }
    
    func replaceNickWithRick(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(NSLocalizedString("NICK", comment: "Nick, literally"), withString: NSLocalizedString("RICK", comment: "Rick, literally"), options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func followWithAccount(account: ACAccount, showToast: Bool = true) {
        TwitterApi(account: account).performQuery("friendships/create", parameters: ["screen_name": "yurijmi"], requestMethod: SLRequestMethod.POST,
            handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        if showToast {
                            Utilities().presentToast("Success!", message: "Successfully followed @yurijmi with @\(account.username)", viewController: self, delay: 3.0)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        Utilities().presentToast("Error!", message: "Something wrong happend while sending follow request from @\(account.username).", viewController: self)
                    }
                }
        })
    }
    
    func followWithAllAccounts(accounts: [ACAccount]) {
        for account in accounts {
            self.followWithAccount(account, showToast: false)
        }
        
        Utilities().presentToast("Success!", message: "Successfully followed @yurijmi with all your Twitter accounts", viewController: self, delay: 3.0)
    }
    
    func selectAccountAndFollow(accounts: [ACAccount]) {
        let actionSheet = UIAlertController(title: "Select Twitter account", message: "You have multiple Twitter accounts connected to your iPhone. Please select account with which you want to follow @yurijmi.", preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "All of them!", style: UIAlertActionStyle.Default, handler: { (actionSheet: UIAlertAction!) in self.followWithAllAccounts(accounts) }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for account in accounts {
            actionSheet.addAction(UIAlertAction(title: "@\(account.username)", style: UIAlertActionStyle.Default, handler: { (actionSheet: UIAlertAction!) in self.followWithAccount(account) }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
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
