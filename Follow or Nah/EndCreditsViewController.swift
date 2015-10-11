//
//  EndCreditsViewController.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 11.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import UIKit

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
    
    @IBAction func followTapped(button: UIButton) {
        
    }
    
    @IBAction func starTapped(button: UIButton) {
        
    }
    
    @IBAction func buyTapped(button: UIButton) {
        
    }
    
}
