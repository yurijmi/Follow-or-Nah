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
    var accountID  : Int?
    var twitterApi : TwitterApi?
    var twitterUsers = [TwitterUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterApi = TwitterApi(account: self.account!)
        
        verifyCredentials()
        getFriends()
    }
    
    func verifyCredentials() {
        self.twitterApi!.performQuery("account/verify_credentials", parameters: ["include_entities": "false", "skip_status": "true", "include_email": "false"],
            handler: { (data :NSData!, response :NSHTTPURLResponse!, error :NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject]
                    
                    self.accountID = response["id"] as? Int
                    
                    let friendCount = response["friends_count"] as! Int
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.headingLabel!.text = "You follow \(friendCount) peeps and this dude"
                    }
                } catch {}
            }
        })
    }
    
    func getFriends() {
        self.twitterApi!.performQuery("friends/ids", handler: { (data :NSData!, response :NSHTTPURLResponse!, error :NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject]
                    
                    var theIDs = (response["ids"] as! [Int]).map { String($0) }
                    
                    if theIDs.count > 100 {
                        theIDs.removeRange(100...theIDs.count)
                    }
                    
                    self.getHydratedUsers(theIDs)
                } catch {}
            }
        })
    }
    
    func getHydratedUsers(twitterIds: [String]) {
        self.twitterApi!.performQuery("users/lookup", parameters: ["user_id": twitterIds, "include_entities": "false"], requestMethod: SLRequestMethod.POST,
            handler: { (data :NSData!, response :NSHTTPURLResponse!, error :NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [AnyObject]
                    
                    for var user in response {
                        user = user as! [String : AnyObject]
                        
                        let twitterUser = TwitterUser(name: user["name"] as! String, userID: user["id"] as! Int, imageURL: user["profile_image_url_https"] as! String, followers: user["followers_count"] as! Int)
                        
                        self.twitterUsers.append(twitterUser)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkFriendship()
                        self.showTopUser()
                    }
                } catch {}
            }
        })
    }
    
    func showTopUser() {
        let user = self.twitterUsers.first!
        
        self.usernameLabel.text = user.name
        self.followersLabel.text = "\(user.followers) followers"
        
        NSURLSession.sharedSession().dataTaskWithURL(user.imageURL) { (data: NSData?, res: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                let image = UIImage(data: data!)
                
                self.imageView.image = image
            }
        }.resume()
    }
    
    func checkFriendship() {
        if self.accountID != nil {
            self.twitterApi!.performQuery("friendships/show", parameters: ["source_id": String(self.accountID!), "target_id": String(self.twitterUsers.first!.userID)],
                handler: { (data :NSData!, response :NSHTTPURLResponse!, error :NSError!) -> Void in
                    if error == nil {
                        do {
                            let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject!]
                            
                            let relationship = response["relationship"] as! [String : AnyObject!]
                            let target       = relationship["target"]   as! [String : AnyObject!]
                            
                            let followingYou = Bool(target["following"] as! Int)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if followingYou {
                                    self.followsYouLabel.text = "Follows you! Let's keep it that way."
                                } else {
                                    self.followsYouLabel.text = "Not following you. What a jerk!"
                                }
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
