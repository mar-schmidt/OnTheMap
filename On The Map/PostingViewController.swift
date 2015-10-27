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
    var error:NSError!
    var pointAnnotation:UdacityPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        // Set the color of the attributes placeholder text to white
        locationTextField.attributedPlaceholder = NSAttributedString(string:"Enter your location here",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.toggleNextButton(self.nextButton, enabled: false)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if (locationTextField.text == "" || locationTextField.text == "Please provide a location") {
            let alertController = UIAlertController(title: "Error", message: "You need to enter a location", preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(dismissAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.showLoadingIndicatorForButton(self.nextButton, show: true)
            self.toggleNextButton(self.nextButton, enabled: false)
            self.makeSearchRequest(self)
        }
    }
    
    func makeSearchRequest(sender: AnyObject) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationTextField.text!, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                
                self.showAlertViewWithTitle("", message: "Place not found")
                self.showLoadingIndicatorForButton(self.nextButton, show: false)
                self.toggleNextButton(self.nextButton, enabled: true)
                
                return
            }
            if placemark!.count > 0 {
                let pm = placemark![0] as CLPlacemark
                print("\(pm.locality), \(pm.country)")
                
                self.pointAnnotation = UdacityPointAnnotation()
                self.pointAnnotation.title = self.locationTextField.text
                let lat = pm.location?.coordinate.latitude
                let long = pm.location?.coordinate.longitude
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude:long!)
                
                self.showLoadingIndicatorForButton(self.nextButton, show: false)
                self.toggleNextButton(self.nextButton, enabled: true)
                
                self.performSegueWithIdentifier("showPostingLinkViewController", sender: sender)
            } else {
                print("Error with data")
                self.showAlertViewWithTitle("", message: "Place not found")
                self.showLoadingIndicatorForButton(self.nextButton, show: false)
                self.toggleNextButton(self.nextButton, enabled: true)
            }
        })
    }
    
    func showAlertViewWithTitle(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func showLoadingIndicatorForButton(button: UIButton, show: Bool) {
        let frame = button.frame
        
        if show {
            button.hidden = true
            
            let activityIndicator = UIActivityIndicatorView()
            // Set the frame of the activityIndicator to the same frame as the button
            activityIndicator.frame = frame
            
            activityIndicator.activityIndicatorViewStyle = .Gray
            activityIndicator.translatesAutoresizingMaskIntoConstraints = true
            
            // Add the activityIndicator as subview of buttons superview
            button.superview?.addSubview(activityIndicator)
            
            // Start the spinning
            activityIndicator.startAnimating()
        } else {
            // Check for the activityView which is still spinning. And then remove it
            for view in (button.superview?.subviews)! {
                if let activityView = view as? UIActivityIndicatorView {
                    activityView.removeFromSuperview()
                }
            }
            
            // If show is false
            button.hidden = false
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
            self.toggleNextButton(self.nextButton, enabled: false)
        } else {
            self.toggleNextButton(self.nextButton, enabled: true)
        }
        
        return true
    }
    
    func toggleNextButton(button: UIButton, enabled: Bool) {
        if enabled {
            button.enabled = true
        } else {
            button.enabled = false
        }
    }

    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}
