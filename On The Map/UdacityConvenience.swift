	//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-06.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    // Authentication (GET) methods
    /*
    Steps for authentication...
    https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true#h.vxj444rdiwwb
    
    Step 1: Get session id
    */
    
    func authenticateWithViewController(hostViewController: UIViewController, username:String!, password:String!, completionHandler: (success: Bool, error: NSError?, errorString: String?) -> Void) {
        
        self.postSessionId(username, password: password) { (success, result, error) -> Void in
            let detailedError = error?.localizedDescription
            
            if let error = error {
                if error.domain == "badCredentials" {
                    completionHandler(success: false, error: error, errorString: "Bad Credentials")
                } else {
                    completionHandler(success: false, error: error, errorString: "Problem occurred when contacting Udacity")
                }
            } else {
                print(result)
                completionHandler(success: success, error: error, errorString: detailedError)
            }
        }
        
    }
    
    func postSessionId(username: String, password: String, completionHandler: (success: Bool, result: UdacityUser?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: [
                UdacityClient.JSONBodyKeys.Username: username,
                UdacityClient.JSONBodyKeys.Password: password
            ]
        ]
    
        /* 2. Make the request */
        taskForPOSTMethod(Methods.AuthenticationSessionNew, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, result: nil, error: error)
            } else {
                var udacityUser = UdacityUser.sharedInstance()
                
                if let sessionResults = JSONResult[UdacityClient.JSONResponseKeys.SessionResults] as? [String : AnyObject] {
                    udacityUser.sessionId = sessionResults[UdacityClient.JSONResponseKeys.SessionID] as? String
                } else {
                    completionHandler(success: false, result: nil, error: NSError(domain: "postSessionId parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postSessionId"]))
                }
                if let accountResults = JSONResult[UdacityClient.JSONResponseKeys.AccountResults] as? [String : AnyObject] {
                    udacityUser.uniqueKey = accountResults[UdacityClient.JSONResponseKeys.UniqueKey] as? String
                    
                    self.getUserData(udacityUser, completionHandler: { (success, result, error) -> Void in
                        if success {
                            udacityUser = result!
                        }
                        completionHandler(success: success, result: result, error: error)
                    })
                } else {
                    completionHandler(success: false, result: nil, error: NSError(domain: "postSessionId parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postSessionId"]))
                }
            }
        }
    }
    
    func getUserData(udacityUser: UdacityUser!, completionHandler: (success: Bool, result: UdacityUser?, error: NSError?) -> Void)  {
        /* 1. Specify parameters, method and HTTP body */
        var mutableMethod = UdacityClient.Methods.UserData
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserId, value: udacityUser.uniqueKey!)!
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: nil) { JSONResult, error in
            
            /* 3. Send the desired values to completionHandler */
            if let error = error {
                completionHandler(success: false, result: nil, error: error)
            } else {
                if let results = JSONResult[UdacityClient.JSONResponseKeys.UserResults] as? [String : AnyObject] {
                    
                    udacityUser.firstName = results[UdacityClient.JSONResponseKeys.FirstName] as? String
                    udacityUser.lastName = results[UdacityClient.JSONResponseKeys.LastName] as? String
                    completionHandler(success: true, result: udacityUser, error: nil)
                } else {
                    completionHandler(success: false, result: nil, error: NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUserData"]))
                }
            }
        }
    }
    
    func logoutFromSession(udacityUser: UdacityUser?, completionHandler: (success: Bool, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        
        /* 2. Make the request */
        taskForDELETEMethod(Methods.Logout, parameters: nil) { success, error in
            
            /* 3. Send the desired value(s) to completion handler */
            completionHandler(success: success, error: error)
        }
    }
}
