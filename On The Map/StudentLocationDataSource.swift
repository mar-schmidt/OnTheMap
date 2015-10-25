//
//  StudentLocationDataSource.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-09.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit


class StudentLocationDataSource: NSObject {
    
    var locations: [ParseStudentLocation] = [ParseStudentLocation]()

    // Shared instance
    class func sharedInstance() -> StudentLocationDataSource {
        
        struct Singleton {
            static var sharedInstance = StudentLocationDataSource()
        }
        
        return Singleton.sharedInstance
    }
}