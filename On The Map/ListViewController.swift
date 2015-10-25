//
//  ListViewController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-09.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParseControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var datasource = StudentLocationDataSource.sharedInstance()
    var parseController = ParseController.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        parseController.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "StudentCell"
        
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath)

        let studentLocation = self.datasource.locations[indexPath.row]
        cell.textLabel?.text = studentLocation.firstName + " " + studentLocation.lastName
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Opening URL \(self.datasource.locations[indexPath.row].mediaURL)")
        UIApplication.sharedApplication().openURL(NSURL(string: self.datasource.locations[indexPath.row].mediaURL)!)
    }
    
    // TabBarControllerDelegate
    func receivedNewStudentLocations() {
        print("Adding new locations to List View")
        self.tableView.reloadData()
    }
}
