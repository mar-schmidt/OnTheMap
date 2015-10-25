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
        parseController.getStudentLocationsWithLimit(100, skip: 0, order: "")
    }
    
    @IBAction func addOwnLocation(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navController = self.navigationController
        
        let postingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PostingViewController")
        self.presentViewController(postingViewController!, animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
    }
}
