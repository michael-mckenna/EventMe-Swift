//
//  EventLocationViewController.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/26/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import MapKit

class EventLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var aptNum: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func alrightPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func checkLocation(sender: AnyObject) {
        view.endEditing(true)
        
        if street.text!.isEmpty || city.text!.isEmpty || state.text!.isEmpty || zip.text!.isEmpty {
            let alert = UIAlertController(title: nil, message: "One or more fields were left empty!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                // ...
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let streetStr = self.street.text! + ", "
        let cityStr = self.city.text! + ", "
        let stateStr = self.state.text!
        
        let address = streetStr + cityStr + stateStr + ", USA"
        
        
//        let address = "7158 Lakeside Dr, Indianapolis, IN, USA"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in

            if((error) != nil){
                print("Invalid Address: " + address)
            }
            
            // zoom map
            if let placemark = placemarks?.first {
                // find region
                let regionRadius: CLLocationDistance = 1000
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                /* handles zoom animation */
                let location = CLLocation(coordinate: coordinates, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate())
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                    regionRadius * 2.0, regionRadius * 2.0)
                self.mapView.setRegion(coordinateRegion, animated: true)
                
                // add pin
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                self.mapView.addAnnotation(annotation)
                
            }
        })
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
