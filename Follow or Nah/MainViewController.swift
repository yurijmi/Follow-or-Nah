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
    
    var account : ACAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func unfollowTapped(button: UIButton) {
        
    }
    
    @IBAction func followTapped(button: UIButton) {
        
    }

}
