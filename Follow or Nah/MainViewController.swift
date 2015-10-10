//
//  MainViewController.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 10.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit
import Accounts
import Social

class MainViewController: UIViewController {
    
    @IBOutlet weak var headingLabel    : UILabel!
    @IBOutlet weak var usernameLabel   : UILabel!
    @IBOutlet weak var imageView       : UIImageView!
    @IBOutlet weak var followersLabel  : UILabel!
    @IBOutlet weak var followsYouLabel : UILabel!
    
    var account    : ACAccount?
    var twitterApi : TwitterApi?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterApi = TwitterApi(account: self.account!)
        
        getFollowersCount()
        getFriends()
    }
    
    func getFollowersCount() {
        self.twitterApi!.performQuery("https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_entities": "false", "skip_status": "true", "include_email": "false"],
            handler: { (data :NSData!, response :NSHTTPURLResponse!, error :NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject]
                    
                    let friendCount = response["friends_count"] as! Int
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.headingLabel!.text = "You follow \(friendCount) peeps and this dude"
                    }
                } catch {}
            }
        })
    }
    }
    
    @IBAction func unfollowTapped(button: UIButton) {
        
    }
    
    @IBAction func followTapped(button: UIButton) {
        
    }

}
