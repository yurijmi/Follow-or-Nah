//
//  TwitterUser.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 11.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import Foundation

class TwitterUser {
    var name     = ""
    var userID   = 0
    var imageURL = NSURL()
    
    init(name: String, userID: Int, imageURL: String) {
        self.name     = name
        self.userID   = userID
        self.imageURL = NSURL(string: imageURL)!
    }
}