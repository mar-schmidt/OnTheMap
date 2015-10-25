//
//  MapViewController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-06.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate ,ParseControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var datasource = StudentLocationDataSource.sharedInstance()
    var parseController = ParseController.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        parseController.getStudentLocationsWithLimit(100, skip: 0, order: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        parseController.delegate = self
    }
    
    func addAnnotationsToMapView(annotations:[ParseStudentLocation], mapView:MKMapView) {
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [UdacityPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        
        for studentLocation in self.datasource.locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(studentLocation.latitude as Double)
            let long = CLLocationDegrees(studentLocation.longitude as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName
            let last = studentLocation.lastName
            let mediaURL = studentLocation.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = UdacityPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            annotation.imageName = "udacity_pin"
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotations(annotations)
        })
        
        
    }
    
    // TabBarControllerDelegate
    func receivedNewStudentLocations() {
        self.addAnnotationsToMapView(self.datasource.locations, mapView: self.mapView)
        print("Adding new locations to Map View")
    }
    
    func errorWhenReceivingStudentLocations() {
        let alertController = UIAlertController(title: "Error", message: "Couldn't fetch student locations. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

