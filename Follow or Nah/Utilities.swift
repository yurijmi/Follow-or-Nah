//
//  Utilities.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 11.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit

class Utilities {
    func presentToast(title: String, message: String, viewController: UIViewController, delay: NSTimeInterval = 1.0, completion: (() -> Void) = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        
        let delay = delay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue()) {
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion()
        }
    }
    
    func updateImageViewAnimated(imageView: UIImageView, newImage: UIImage, duration: NSTimeInterval = 0.5) {
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(duration)
        
        let transition = CATransition()
        transition.type = kCATransitionFade
        
        imageView.layer.addAnimation(transition, forKey: kCATransition)
        imageView.image = newImage
        
        CATransaction.commit()
    }
}
