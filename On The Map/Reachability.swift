//
//  Reachability.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-25.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit

public class Reachability {
        
    class func isValidUrl(url: NSURL?) -> Bool {
        //Check for nil
        if let urlString = url?.absoluteString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    class func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    class func hasHTTPSchemeForString(urlString: String) -> Bool {
        
        if urlString.hasPrefix("http://") {
            return true
        } else {
            return false
        }
    }
    
    class func applyHTTPSchemeForURL(url: NSURL) -> String? {
        let components = NSURLComponents()
        components.scheme = "http";
        if let validHost: String = url.absoluteString {
            components.host = validHost;
            
            if let validUrl = components.URL?.absoluteString {
                return validUrl
            } else {
                return "http://"
            }
        }
    }
}