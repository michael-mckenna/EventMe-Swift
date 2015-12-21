//
//  CreateEventViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/19/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//
import UIKit
import Parse
import MapKit
import CoreLocation

class CreateEventViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var tagsInput: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var map: MKMapView!
    var thisLong = 0.0
    var thisLat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 1.0
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            var touchPoint = gestureRecognizer.locationInView(self.map)
            
            var newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            var location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                
                if (error == nil) {
                    
                    //if statement was changed
                    if let p = placemarks?[0] {
                        
                        
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        
                        if p.subThoroughfare != nil {
                            
                            subThoroughfare = p.subThoroughfare!
                            
                        }
                        
                        if p.thoroughfare != nil {
                            
                            thoroughfare = p.thoroughfare!
                            
                        }
                        
                        self.addressLabel.text = "\(subThoroughfare) \(thoroughfare)"
                    }
                    
                }
                
                if title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                    
                    title = "Added \(NSDate())"
                    
                }
                
                print(title)
                
                var annotation = MKPointAnnotation()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //deleted 'as [CLLocation]'
        var userLocation:CLLocation = locations[0]
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        var coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.thisLat = userLocation.coordinate.latitude
        self.thisLong = userLocation.coordinate.longitude
       
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
            
            if (error != nil) {
                
                print(error)
                
            } else {
                
                if let p = placemarks?[0] {
                    
                    var subThoroughfare:String = ""
                    
                    if (p.subThoroughfare != nil) {
                        
                        subThoroughfare = p.subThoroughfare!
                        
                    }
                    
                    self.addressLabel.text = "\(subThoroughfare) \(p.thoroughfare!), \(p.locality!), \(p.administrativeArea!) \(p.postalCode!)"
                }
            }
        })

        self.map.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveEvent(sender: AnyObject) {
        //alertdialog first to check if fields are blank
        
        var point = PFGeoPoint(latitude: 0.0, longitude: 0.0)
        point.latitude = self.thisLat
        point.longitude = self.thisLong
        
        var event = PFObject(className: "Event")
        event["eventName"] = self.nameInput.text
        event["eventDescription"] = self.descriptionInput.text
        event["eventLocation"] = point
        event["votes"] = 0
        event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                print("Successfully saved event\n")
                print(point)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        
    }
    

}