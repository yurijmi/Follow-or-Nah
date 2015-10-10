//
//  TwitterApi.swift
//  Follow or Nah
//
//  Created by Юрий Михайлов on 10.10.15.
//  Copyright © 2015 Юрий Михайлов. All rights reserved.
//

import Foundation
import Accounts
import Social

class TwitterApi {
    var account: ACAccount
    
    init(account: ACAccount) {
        self.account = account
    }
    
    func performQuery(url: String, requestMethod: SLRequestMethod = SLRequestMethod.GET, parameters: [NSObject : AnyObject]? = nil, handler: SLRequestHandler!) {
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: NSURL(string: url), parameters: parameters)
            request.account = self.account
        
        request.performRequestWithHandler(handler)
    }
}