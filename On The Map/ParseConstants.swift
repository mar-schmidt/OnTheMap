//
//  ParseConstants.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-09.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        static let BaseURLSecure : String = "https://api.parse.com/1/classes/StudentLocation?"
    }
    
    struct Methods {
        static let ObjectId = "{objectId}"
        static let Where = "where="
    }
    
    struct ParameterKeys {
        static let Limit = "limit" //(Number) specifies the maximum number of StudentLocation objects to return in the JSON response
        static let Skip = "skip" //(Number) use this parameter with limit to paginate through results
        static let Order = "order" //(String) a comma-separate list of key names that specify the sorted order of the results Prefixing a key name with a negative sign reverses the order (default order is descending) ex: https://api.parse.com/1/classes/StudentLocation?order=-updatedAt
        
        //static let Where = "where="
    }
    
    struct JSONResponseKeys {
        // GET StudentLocation
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        
        static let StudentLocationResults = "results"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}