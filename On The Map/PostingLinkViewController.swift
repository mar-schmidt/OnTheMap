//
//  PostingLinkViewController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-11.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import MapKit

class PostingLinkViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var mapString:String!
    var pointAnnotation:UdacityPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var datasource = StudentLocationDataSource.sharedInstance()
    var parentVC: UIViewController!
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    override func viewDidLoad() {
        // Set the color of the attributes placeholder text to white
        self.linkTextField.attributedPlaceholder = NSAttributedString(string:"Enter a link to share",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.pointAnnotation.imageName = "udacity_pin"
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        
        self.toggleShareButton(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 5000, 5000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion);
        self.mapView.setRegion(adjustedRegion, animated: true)
        
        //self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (linkTextField.text == "") {
            let alertController = UIAlertController(title: "Issue", message: "Please provide a link", preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(dismissAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        if (!Reachability.hasHTTPSchemeForString(linkTextField.text!)) {
            let linkUrl = NSURL(string: linkTextField.text!)
            linkTextField.text = Reachability.applyHTTPSchemeForURL(linkUrl!)
        }
        
        let udacityUser = UdacityUser.sharedInstance()
        
        // Create the studentLocation object
        let studentLocationDict: [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: udacityUser.uniqueKey as String!,
            ParseClient.JSONBodyKeys.FirstName: udacityUser.firstName as String!,
            ParseClient.JSONBodyKeys.LastName: udacityUser.lastName as String!,
            ParseClient.JSONBodyKeys.MapString: self.mapString,
            ParseClient.JSONBodyKeys.MediaUrl: self.linkTextField.text!,
            ParseClient.JSONBodyKeys.Latitude: self.pointAnnotation.coordinate.latitude,
            ParseClient.JSONBodyKeys.Longitude: self.pointAnnotation.coordinate.longitude
        ]
        
        let studentLocation = ParseStudentLocation.studenLocationFromDictionary(studentLocationDict)
        
        ParseClient.sharedInstance().postStudentLocation(studentLocation) { (result, error) -> Void in
            if let studentLocation = result {
                self.datasource.locations.append(studentLocation)
                print("New studentLocation created with objectId: \(studentLocation.objectId)")
                
                self.dismissToPresentingViewController()
            }
        }
    }
    
    func dismissToPresentingViewController() {

        // Save the presenting ViewController
        let presentingViewController: UIViewController! = self.presentingViewController;
        
        self.dismissViewControllerAnimated(false) {
            // go back to MainMenuView as the eyes of the user
            presentingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                let parseController = ParseController.sharedInstance()
                parseController.getStudentLocationsWithLimit(100, skip: 0, order: "")
            })
        }
    }
     
    // MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        dispatch_async(dispatch_get_main_queue(), {
            let cpa = annotation as! UdacityPointAnnotation
            pinView!.image = UIImage(named: cpa.imageName)
        })
        
        return pinView
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text
        let newLength = text!.characters.count + string.characters.count - range.length
        
        if newLength == 0 {
            self.toggleShareButton(false)
        } else {
            self.toggleShareButton(true)
        }
        
        return true
    }
    
    func toggleShareButton(enabled: Bool) {
        if enabled {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
    }
}
