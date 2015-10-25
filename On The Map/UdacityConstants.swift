//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-06.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

extension UdacityClient {
    
    // Constants
    struct Constants {
        
        // URLs
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        
        // Authentication
        static let AuthenticationSessionNew = "session"
        static let UserData = "users/{user_id}"
    }
    
    struct URLKeys {
        static let UserId = "user_id"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        
        // General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // Authorization
        static let SessionResults = "session"
        static let SessionID = "id"
        
        static let AccountResults = "account"
        static let UniqueKey = "key"
        
        
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
        static let UserResults = "user"
    }
}
