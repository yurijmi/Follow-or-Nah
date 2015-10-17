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
import Kingfisher

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
    var imageTask  : RetrieveImageTask?
    
    var friendCount  = 0
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
                            
                            Utilities().presentToast(NSLocalizedString("ERROR", comment: "Error with a !"), message: NSLocalizedString("ERROR_TWITTER_PROFILE", comment: "Message about error while getting profile information"), viewController: self.view.window!.rootViewController!, delay: 5.0)
                        }
                    } else {
                        self.accountID = response["id"] as? Int
                        
                        self.friendCount = response["friends_count"] as! Int
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.headingLabel!.text = String.localizedStringWithFormat(NSLocalizedString("FOLLOWING_HEADING", comment: "Following heading with count"), self.friendCount)
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
                            
                            Utilities().presentToast(NSLocalizedString("ERROR", comment: "Error with a !"), message: NSLocalizedString("ERROR_TWITTER_FRIENDS", comment: "Message about error while getting people you follow"), viewController: self.view.window!.rootViewController!, delay: 5.0)
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
                            
                            Utilities().presentToast(NSLocalizedString("ERROR", comment: "Error with a !"), message: NSLocalizedString("ERROR_TWITTER_FRIENDS", comment: "Message about error while getting people you follow"), viewController: self.view.window!.rootViewController!, delay: 5.0)
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
            self.twitterUsers.removeFirst()
        }
        
        if self.twitterUsers.count > 0 {
            let user = self.twitterUsers.first!
            
            // Checking if displaying first user
            if self.headingLabel.alpha == 0.0 {
                self.usernameLabel.text  = user.name
                self.followersLabel.text = String.localizedStringWithFormat(NSLocalizedString("FOLLOWERS_COUNT", comment: "Followers count"), user.followers)
            } else {
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.usernameLabel.alpha  = 0.0
                    self.followersLabel.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    self.usernameLabel.text  = user.name
                    self.followersLabel.text = String.localizedStringWithFormat(NSLocalizedString("FOLLOWERS_COUNT", comment: "Followers count"), user.followers)
                    
                    UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.usernameLabel.alpha  = 1.0
                        self.followersLabel.alpha = 1.0
                    }, completion: nil)
                })
            }
            
            if self.headingLabel.alpha == 1.0 {
                self.checkFriendship()
            }
            
            /***\ AVATAR STUFF UP NEXT \***/
            
            // Function for displaying everything if first user or just fading in the image
            func showOrFadeImage(image: UIImage) {
                dispatch_async(dispatch_get_main_queue()) {
                    if self.headingLabel.alpha == 0.0 {
                        self.imageView.image = image
                        
                        // Fade in all stuff and stop animating the indicator
                        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.headingLabel.alpha    = 1.0
                            self.usernameLabel.alpha   = 1.0
                            self.imageView.alpha       = 1.0
                            self.followersLabel.alpha  = 1.0
                            self.unfollowButton.alpha  = 1.0
                            self.followButton.alpha    = 1.0
                        }, completion: nil)
                        
                        self.actInd!.stopAnimating()
                        
                        self.checkFriendship()
                    } else {
                        // Fade in the image view
                        Utilities().updateImageViewAnimated(self.imageView, newImage: image)
                    }
                }
            }
            
            func downloadSmallImageAndThenBigImage() {
                if self.imageTask != nil {
                    self.imageTask!.cancel()
                }
                
                self.imageTask = KingfisherManager.sharedManager.retrieveImageWithResource(Resource(downloadURL: user.imageURL),
                    optionsInfo: nil,
                    progressBlock: nil,
                    completionHandler: { (image: UIImage?, error: NSError?, cacheType: CacheType, imageURL: NSURL?) -> () in
                        if error == nil {
                            showOrFadeImage(image!)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // Downloading bigger image
                                self.imageTask = KingfisherManager.sharedManager.retrieveImageWithResource(Resource(downloadURL: user.bigImageURL),
                                    optionsInfo: nil,
                                    progressBlock: nil,
                                    completionHandler: { (image: UIImage?, error: NSError?, cacheType: CacheType, imageURL: NSURL?) -> () in
                                        if error == nil {
                                            dispatch_async(dispatch_get_main_queue()) {
                                                self.imageView.image = image
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                )
            }
            
            // Checking if we have big image in cache
            KingfisherManager.sharedManager.cache.retrieveImageForKey(Resource(downloadURL: user.bigImageURL).cacheKey, options: KingfisherManager.DefaultOptions, completionHandler: { (image, cacheType) -> () in
                image == nil ? downloadSmallImageAndThenBigImage() : showOrFadeImage(image!)
            })
        } else {
            if self.friendsIDs.count > 0 {
                var theIDs = self.friendsIDs
                
                if self.friendsIDs.count > 100 {
                    self.friendsIDs.removeRange(0...99)
                    
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
        
        var followsText = NSLocalizedString("ERROR_CHECK_FOLLOWING", comment: "Can't determine if follows or not")
        
        if self.accountID != nil {
            self.twitterApi!.performQuery("friendships/show", parameters: ["source_id": String(self.accountID!), "target_id": String(self.twitterUsers.first!.userID)],
                handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                    if error == nil {
                        do {
                            let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject!]
                            
                            if response["errors"] == nil {
                                let relationship = response["relationship"] as! [String : AnyObject!]
                                let target       = relationship["target"]   as! [String : AnyObject!]
                                
                                followsText = Bool(target["following"] as! Int) ? NSLocalizedString("FOLLOWS_YOU", comment: "Follows you label's text") : NSLocalizedString("NOT_FOLLOWING_YOU", comment: "Follows you label's text")
                            }
                        } catch {}
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.followsYouLabel.text = followsText
                        
                        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.followsYouLabel.alpha = 1.0
                        }, completion: nil)
                    }
            })
        } else {
            self.followsYouLabel.text = followsText
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.followsYouLabel.alpha = 1.0
            }, completion: nil)
        }
    }
    
    @IBAction func unfollowTapped(button: UIButton) {
        self.twitterApi!.performQuery("friendships/destroy", parameters: ["user_id": String(self.twitterUsers.first!.userID)], requestMethod: SLRequestMethod.POST,
            handler: { (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error == nil {
                    self.friendCount--
                    
                    if self.friendsIDs.count > 0 {
                        self.friendsIDs.removeFirst()
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.headingLabel!.text = String.localizedStringWithFormat(NSLocalizedString("FOLLOWING_HEADING", comment: "Following heading with count"), self.friendCount)
                        
                        Utilities().presentToast(NSLocalizedString("SUCCESS", comment: "Success with a !"), message: String.localizedStringWithFormat(NSLocalizedString("SUCCESS_UNFOLLOW", comment: "Message about successfully unfollowing a user"), self.twitterUsers.first!.name), viewController: self, completion: { self.showNextUser() })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        Utilities().presentToast(NSLocalizedString("ERROR", comment: "Error with a !"), message: NSLocalizedString("ERROR_TWITTER_UNFOLLOW", comment: "Message about error while unfollowing"), viewController: self)
                    }
                }
        })
    }
    
    @IBAction func followTapped(button: UIButton) {
        showNextUser()
    }
    
    @IBAction func dropCacheTapped(button: UIBarButtonItem) {
        let cache = KingfisherManager.sharedManager.cache
        
        // Clear memory cache
        cache.clearMemoryCache()
        
        // Clear disk cache
        cache.clearDiskCache()
        
        Utilities().presentToast(NSLocalizedString("DONE", comment: "Done with a !"), message: NSLocalizedString("SUCCESS_IMAGE_CACHE_DROPPED", comment: "Message about successful cache drop"), viewController: self)
    }

}
