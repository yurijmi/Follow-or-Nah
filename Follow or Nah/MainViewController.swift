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
    @IBOutlet weak var unfollowButton  : UIButton!
    @IBOutlet weak var followButton    : UIButton!
    
    var actInd     : UIActivityIndicatorView?
    var account    : ACAccount?
    var accountID  : Int?
    var twitterApi : TwitterApi?
    
    var friendsIDs   = [String]()
    var twitterUsers = [TwitterUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterApi = TwitterApi(account: self.account!)
        
        spawnActivityIndicator()
        
        verifyCredentials()
        getFriends()
    }
    
    func spawnActivityIndicator() {
        self.actInd = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
        
        self.actInd!.center                     = self.view.center
        self.actInd!.hidesWhenStopped           = true
        self.actInd!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(self.actInd!)
        
        self.actInd!.startAnimating()
    }
    
    func verifyCredentials() {
        self.twitterApi!.performQuery("account/verify_credentials", parameters: ["include_entities": "false", "skip_status": "true", "include_email": "false"],
            handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject]
                    
                    if response["errors"] != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController!.popToRootViewControllerAnimated(true)
                            
                            Utilities().presentToast("Error!", message: "Twitter responded with error while requesting info about your profile. Please, try again and if the problem persists try again in 15 minutes.", viewController: self.view.window!.rootViewController!, delay: 5.0)
                        }
                    } else {
                        self.accountID = response["id"] as? Int
                        
                        let friendCount = response["friends_count"] as! Int
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.headingLabel!.text = "You follow \(friendCount) peeps and this dude"
                        }
                    }
                } catch {}
            }
        })
    }
    
    func getFriends() {
        self.twitterApi!.performQuery("friends/ids", handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject]
                    
                    if response["errors"] != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController!.popToRootViewControllerAnimated(true)
                            
                            Utilities().presentToast("Error!", message: "Twitter responded with error while requesting info about peeps you follow. Please, try again and if the problem persists try again in 15 minutes.", viewController: self.view.window!.rootViewController!, delay: 5.0)
                        }
                    } else {
                        var theIDs = (response["ids"] as! [Int]).map { String($0) }
                        
                        if theIDs.count > 0 {
                            if theIDs.count > 100 {
                                self.friendsIDs = theIDs
                                self.friendsIDs.removeRange(0...99)
                                
                                theIDs.removeRange(100...(theIDs.count - 1))
                            }
                            
                            self.getHydratedUsers(theIDs)
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EndCreditsViewController") as! EndCreditsViewController
                                    vc.noFriends = true
                                
                                self.presentViewController(vc, animated: true, completion: nil)
                            }
                        }
                    }
                } catch {}
            }
        })
    }
    
    func getHydratedUsers(twitterIds: [String]) {
        self.twitterApi!.performQuery("users/lookup", parameters: ["user_id": twitterIds, "include_entities": "false"], requestMethod: SLRequestMethod.POST,
            handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    
                    if response as? [String : AnyObject] != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController!.popToRootViewControllerAnimated(true)
                            
                            Utilities().presentToast("Error!", message: "Twitter responded with error while requesting info about peeps you follow. Please, try again and if the problem persists try again in 15 minutes.", viewController: self.view.window!.rootViewController!, delay: 5.0)
                        }
                    } else {
                        let responseArr = response as! [AnyObject]
                        
                        for var user in responseArr {
                            user = user as! [String : AnyObject]
                            
                            let twitterUser = TwitterUser(name: user["name"] as! String, userID: user["id"] as! Int, imageURL: user["profile_image_url_https"] as! String, followers: user["followers_count"] as! Int)
                            
                            self.twitterUsers.append(twitterUser)
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showNextUser(false)
                        }
                    }
                } catch {}
            }
        })
    }
    
    func showNextUser(removeFromQueue: Bool = true) {
        if removeFromQueue {
            self.twitterUsers.removeAtIndex(0)
        }
        
        if self.twitterUsers.count > 0 {
            let user = self.twitterUsers.first!
            
            // Checking if displaying first user
            if self.headingLabel.alpha == 0.0 {
                self.usernameLabel.text  = user.name
                self.followersLabel.text = "\(user.followers) followers"
            } else {
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.usernameLabel.alpha  = 0.0
                    self.followersLabel.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    self.usernameLabel.text  = user.name
                    self.followersLabel.text = "\(user.followers) followers"
                    
                    UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.usernameLabel.alpha  = 1.0
                        self.followersLabel.alpha = 1.0
                    }, completion: nil)
                })
            }
            
            self.checkFriendship()
            
            NSURLSession.sharedSession().dataTaskWithURL(user.imageURL) { (data: NSData?, res: NSURLResponse?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let image = UIImage(data: data!)
                    
                    if self.headingLabel.alpha == 0.0 {
                        self.imageView.image = image
                        
                        // Fade in all stuff and stop animating the indicator
                        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.headingLabel.alpha    = 1.0
                            self.usernameLabel.alpha   = 1.0
                            self.imageView.alpha       = 1.0
                            self.followersLabel.alpha  = 1.0
                            self.followsYouLabel.alpha = 1.0
                            self.unfollowButton.alpha  = 1.0
                            self.followButton.alpha    = 1.0
                        }, completion: nil)
                        
                        self.actInd!.stopAnimating()
                    } else {
                        // Fade in the image view
                        Utilities().updateImageViewAnimated(self.imageView, newImage: image!)
                    }
                }
            }.resume()
        } else {
            if self.friendsIDs.count > 0 {
                var theIDs = self.friendsIDs
                
                if self.friendsIDs.count > 100 {
                    theIDs.removeRange(100...(theIDs.count - 1))
                }
                
                getHydratedUsers(theIDs)
            } else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EndCreditsViewController") as! EndCreditsViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func checkFriendship() {
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.followsYouLabel.alpha = 0.0 }, completion: nil)
        
        var followsText = "Can't determine if user follows you or not"
        
        if self.accountID != nil {
            self.twitterApi!.performQuery("friendships/show", parameters: ["source_id": String(self.accountID!), "target_id": String(self.twitterUsers.first!.userID)],
                handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                    if error == nil {
                        do {
                            let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject!]
                            
                            if response["errors"] == nil {
                                let relationship = response["relationship"] as! [String : AnyObject!]
                                let target       = relationship["target"]   as! [String : AnyObject!]
                                
                                followsText = Bool(target["following"] as! Int) ? "Follows you! Let's keep it that way." : "Not following you. What a jerk!"
                            }
                        } catch {}
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.followsYouLabel.text = followsText
                        
                        // Checking if displaying first user
                        if self.headingLabel.alpha != 0.0 {
                            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.followsYouLabel.alpha = 1.0
                            }, completion: nil)
                        }
                    }
            })
        } else {
            self.followsYouLabel.text = followsText
            
            // Checking if displaying first user
            if self.headingLabel.alpha != 0.0 {
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.followsYouLabel.alpha = 1.0
                }, completion: nil)
            }
        }
    }
    
    @IBAction func unfollowTapped(button: UIButton) {
        self.twitterApi!.performQuery("friendships/destroy", parameters: ["user_id": String(self.twitterUsers.first!.userID)], requestMethod: SLRequestMethod.POST,
            handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        Utilities().presentToast("Success!", message: "\(self.twitterUsers.first!.name) has been successfully unfollowed!", viewController: self, completion: { self.showNextUser() })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        Utilities().presentToast("Error!", message: "Something wrong happend while sending unfollow request.", viewController: self)
                    }
                }
        })
    }
    
    @IBAction func followTapped(button: UIButton) {
        showNextUser()
    }

}
