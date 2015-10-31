//
//  ParseClient.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-09.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    /* Shared session */
    var session: NSURLSession
    
    // Initializers
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Shared instance
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // GET
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        
        
        /* 2/3. Build the URL and configure the request */
        var urlString = Constants.BaseURLSecure + method
        if (parameters != nil) {
            urlString = urlString + ParseClient.escapedParameters(parameters!)
        }
        print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        request.addValue(ParseClient.Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Api.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response from server \(response?.description)'"]
                completionHandler(result: nil, error: NSError(domain: "invalidResponseCompletionHandler", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: error)
                
                return
            }
            
            /* 5/6. Parse the data and use the data */
            
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // POST
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        
        
        /* 2/3. Build the URL and configure the request */
        var urlString = Constants.BaseURLSecure + method
        if (parameters != nil) {
            urlString = urlString + ParseClient.escapedParameters(parameters!)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        request.HTTPMethod = "POST"
        request.addValue(ParseClient.Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Api.Key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            let string1 = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
            print(string1)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response from server \(response?.description)'"]
                completionHandler(result: nil, error: NSError(domain: "invalidResponseCompletionHandler", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* 5/6. Parse the data and use the data */
            
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // Helpers
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print(parsedResult)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
