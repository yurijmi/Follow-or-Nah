//
//  TwitterUser.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 11.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import Foundation

class TwitterUser {
    var name        = ""
    var userID      = 0
    var imageURL    = NSURL()
    var bigImageURL = NSURL()
    var followers   = 0
    
    init(name: String, userID: Int, imageURL: String, followers: Int) {
        self.name        = name
        self.userID      = userID
        self.imageURL    = NSURL(string: imageURL.stringByReplacingOccurrencesOfString("_normal.", withString: "_bigger.", options: NSStringCompareOptions.LiteralSearch, range: nil))!
        self.bigImageURL = NSURL(string: imageURL.stringByReplacingOccurrencesOfString("_normal.", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil))!
        self.followers   = followers
    }
}