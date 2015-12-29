//
//  CreateEventViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/19/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//
import UIKit
import Parse
import GoogleMaps

class CreateEventViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var tagsInput: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    var thisLong = 0.0
    var thisLat = 0.0
    var imagePicker: UIImagePickerController!
    var image = UIImage?()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var placePicker: GMSPlacePicker?
    var myLocation: PFGeoPoint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameInput.delegate = self
        descriptionInput.delegate = self
        tagsInput.delegate = self
        
        //setting up the image picker
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
       
        //gets user's current location via Parse API's GeoPoint
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.thisLat = geoPoint!.latitude
                self.thisLong = geoPoint!.longitude
            } else {
                print("Error retreiving current location")
            }
        }
        
    }

        @IBAction func showAction(sender: AnyObject) {
            
            //actions sheet for photo options
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveEvent(sender: AnyObject) {
        
        //alertdialog first to check if fields are blank
        if self.nameInput.text!.isEmpty || self.descriptionInput.text.isEmpty || self.tagsInput.text!.isEmpty {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "One or more fields were left blank!"
            alert.addButtonWithTitle("OK")
            alert.show()
            return
        }
        
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
    
    @IBAction func addLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2DMake(self.thisLat, self.thisLong)
        //defining rectangular bounds defining the initial rectangular area that the place picker's map must show
        let northEast = CLLocationCoordinate2DMake(self.thisLat + 0.0001, self.thisLong + 0.0001)
        let southWest = CLLocationCoordinate2DMake(self.thisLat - 0.001, self.thisLong - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
            } else {
                print("No place selected")
            }
        })
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