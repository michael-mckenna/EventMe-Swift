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

class CreateEventViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var tagsInput: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet weak var imageView: UIImageView!

    var thisLong = 0.0
    var thisLat = 0.0
    var manager: CLLocationManager!
    var imagePicker: UIImagePickerController!
    var image = UIImage?()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameInput.delegate = self
        descriptionInput.delegate = self
        tagsInput.delegate = self
        
        //setting up the image picker
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        
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
    
        @IBAction func showAction(sender: AnyObject) {
            
            let alert = UIAlertController(title: "Photo Source", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Photo", style: .Default, handler: { (action) -> Void in
                self.imagePicker.sourceType = .Camera

                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Library", style: .Default, handler: { (action) -> Void in
    
                self.imagePicker.sourceType = .PhotoLibrary
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                //do nothing
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

    //function called once a photo is taken/chosen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.imageView.image = resizeImage(self.image!, newWidth: 200)
        self.image = self.imageView.image
        //self.imageView.contentMode = .ScaleAspectFit
    }
    
    //function called when the user cancels photo picking
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
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
        
        //getting image data ready
        if let imageData = UIImagePNGRepresentation(self.image!) {
            let imageFile: PFFile!
            imageFile = PFFile(name: "image.png", data: imageData)
            event["eventImage"] = imageFile
        }
        
        progressBarDisplayer("Saving Event", true)
        event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                print("Successfully saved event\n")
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        
    }
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 100, width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor.grayColor()
        
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }
    
    
    //closes keyboard when user touches outside of the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //closes keyboard when user taps the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    

}