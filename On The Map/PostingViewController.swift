//
//  PostingViewController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-11.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:UdacityPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        // Set the color of the attributes placeholder text to white
        locationTextField.attributedPlaceholder = NSAttributedString(string:"Enter your location here",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.toggleNextButton(false)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if (locationTextField.text == "" || locationTextField.text == "Please provide a location") {
            let alertController = UIAlertController(title: "Error", message: "You need to enter a location", preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(dismissAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.toggleNextButton(false)
            self.makeSearchRequest(self)
        }
    }
    
    func makeSearchRequest(sender: AnyObject) {
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                self.toggleNextButton(true)
                
                return
            }
            
            self.pointAnnotation = UdacityPointAnnotation()
            self.pointAnnotation.title = self.locationTextField.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: localSearchResponse!.boundingRegion.center.latitude,
                longitude:localSearchResponse!.boundingRegion.center.longitude
            )
            print("Lat: \(localSearchResponse!.boundingRegion.center.latitude) Long: \(localSearchResponse!.boundingRegion.center.longitude)")
            
            self.toggleNextButton(true)
            
            self.performSegueWithIdentifier("showPostingLinkViewController", sender: sender)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPostingLinkViewController" {
            let postingLinkViewController = segue.destinationViewController as! PostingLinkViewController

            postingLinkViewController.parentVC = self
            postingLinkViewController.pointAnnotation = self.pointAnnotation
            postingLinkViewController.mapString = locationTextField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.findOnTheMap(self)
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text
        let newLength = text!.characters.count + string.characters.count - range.length
        
        if newLength == 0 {
            self.toggleNextButton(false)
        } else {
            self.toggleNextButton(true)
        }
        
        return true
    }
    
    func toggleNextButton(enabled: Bool) {
        if enabled {
            nextButton.enabled = true
        } else {
            nextButton.enabled = false
        }
    }

    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}
