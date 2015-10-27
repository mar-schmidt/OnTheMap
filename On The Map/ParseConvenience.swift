//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-09.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudentLocationsWithLimit(limit: Int, skip: Int, order: String?, completionHandler: (result: [ParseStudentLocation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method and HTTP body */
        let parameters : [String : AnyObject] = [
            ParseClient.ParameterKeys.Limit: limit,
            ParseClient.ParameterKeys.Skip: skip,
            ParseClient.ParameterKeys.Order: order!
        ]
        
        /* 2. Make the request */
        taskForGETMethod("", parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired values to completionHandler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult[ParseClient.JSONResponseKeys.StudentLocationResults] as? [[String : AnyObject]] {
                    
                    let studentLocations = ParseStudentLocation.studentLocationsFromResults(results)
                    completionHandler(result: studentLocations, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocationsWithLimit parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocationsWithLimit"]))
                }
            }
        }
    }
    
    func postStudentLocation(studentLocation: ParseStudentLocation, completionHandler: (result: ParseStudentLocation?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method and HTTP body */
        
        var jsonBody: [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: studentLocation.uniqueKey as String!,
            ParseClient.JSONBodyKeys.FirstName: studentLocation.firstName,
            ParseClient.JSONBodyKeys.LastName: studentLocation.lastName,
            ParseClient.JSONBodyKeys.MapString: studentLocation.mapString,
            ParseClient.JSONBodyKeys.MediaUrl: studentLocation.mediaURL,
            ParseClient.JSONBodyKeys.Latitude: studentLocation.latitude,
            ParseClient.JSONBodyKeys.Longitude: studentLocation.longitude
        ]
        
        /* 2. Make the request */
        taskForPOSTMethod("", parameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired values to completionHandler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if (JSONResult != nil) {
                    
                    jsonBody[ParseClient.JSONResponseKeys.CreatedAt] = JSONResult[ParseClient.JSONResponseKeys.CreatedAt]
                    jsonBody[ParseClient.JSONResponseKeys.UpdatedAt] = JSONResult[ParseClient.JSONResponseKeys.CreatedAt]
                    jsonBody[ParseClient.JSONResponseKeys.ObjectId] = JSONResult[ParseClient.JSONResponseKeys.ObjectId]
                    
                    let studentLocation = ParseStudentLocation.studenLocationFromDictionary(jsonBody)
                    
                    completionHandler(result: studentLocation, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocationsWithLimit parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocationsWithLimit"]))
                }
            }
        }
    }
    
    func createStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: NSNumber, longitude: NSNumber) -> ParseStudentLocation {
        // Create the studentLocation object
        let studentLocationDict: [String : AnyObject] = [
            JSONBodyKeys.UniqueKey: uniqueKey,
            JSONBodyKeys.FirstName: firstName,
            JSONBodyKeys.LastName: lastName,
            JSONBodyKeys.MapString: mapString,
            JSONBodyKeys.MediaUrl: mediaUrl,
            JSONBodyKeys.Latitude: latitude,
            JSONBodyKeys.Longitude: longitude
        ]
        
        let studentLocation = ParseStudentLocation.studenLocationFromDictionary(studentLocationDict)
        
        return studentLocation
    }
    
    /* Helper: return a string from current date*/
    func currentDateInString() -> String {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.AAA'Z'" //"2015-10-09T00:20:27.444Z"
        
        return dateFormatter.stringFromDate(date)
    }
}