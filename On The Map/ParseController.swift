//
//  ParseController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-11.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

protocol ParseControllerDelegate {
    func receivedNewStudentLocations()
    func errorWhenReceivingStudentLocations()
}

class ParseController: NSObject {
    
    var delegate: ParseControllerDelegate?
    var datasource = StudentLocationDataSource.sharedInstance()
    
    // Shared instance
    static func sharedInstance() -> ParseController {
        struct Singleton {
            static var sharedInstance = ParseController()
        }
        return Singleton.sharedInstance
    }
    
    func getStudentLocationsWithLimit(limit: Int, skip: Int, order: String?, completionHandler: (result: [ParseStudentLocation]?, error: NSError?) -> Void) {
        ParseClient.sharedInstance().getStudentLocationsWithLimit(limit, skip: skip, order: order) { (result, error) -> Void in

            if let studentLocations = result {
                self.datasource.locations = studentLocations
                print("Received \(self.datasource.locations.count) new locations")
                self.delegate?.receivedNewStudentLocations()
            } else {
                self.delegate?.errorWhenReceivingStudentLocations()
            }
            completionHandler(result: result, error: error)
        }
    }
}
