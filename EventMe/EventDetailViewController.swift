//
//  EventDetailViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/20/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    

    
    //the optional is a "failable" initializer so we can check if the image is nil (not there)
    var image = UIImage?()
    var nameText = String()
    var descText = String()
    var addressText = String()
    var location = CLLocation()
    var userImageObject = PFObject(className: "Event")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                if let p = placemarks?[0] {
                    var subThoroughfare: String = ""
                    if p.subThoroughfare != nil {
                        subThoroughfare = p.subThoroughfare!
                        //breaks down the different parts of an address. See documentation for each component
                        self.addressLabel.text = "\(subThoroughfare) \(p.thoroughfare!) \n \(p.locality!), \(p.administrativeArea!) \(p.postalCode!)"
                    }
                    
                }
            }
        })
    
        self.eventName.text = nameText
        
        self.descLabel.text = descText
        self.addressLabel.text = addressText
        
        //image
        if let userImageFile = self.userImageObject["eventImage"] as? PFFile {
           userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                print("No error extracting image")
                if imageData != nil {
                    self.image = UIImage(data: imageData!)
                    self.eventImage.image = self.image
                    print("There is an image")
                } else {
                    print("There was no image")
                }
            }
        }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
