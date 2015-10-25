//
//  UdacityUser.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-11.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

class UdacityUser: NSObject {
    var sessionId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    
    // Shared instance
    class func sharedInstance() -> UdacityUser {
        struct Singleton {
            static var sharedInstance = UdacityUser()
        }
        return Singleton.sharedInstance
    }
}