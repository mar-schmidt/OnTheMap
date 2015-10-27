//
//  TabBarController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-11.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var parseController = ParseController.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func refreshStudentLocations(sender: AnyObject) {
        parseController.getStudentLocationsWithLimit(100, skip: 0, order: "-updatedAt") { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Error", message: "Error when receiving updated locations.\n\(error.localizedDescription) Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(dismissAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func addOwnLocation(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navController = self.navigationController
        
        let postingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PostingViewController")
        self.presentViewController(postingViewController!, animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        let udacityClient = UdacityClient.sharedInstance()
        udacityClient.logoutFromSession(nil) { (success, error) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: "Could not logout from Udacity right now", preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(dismissAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
}
