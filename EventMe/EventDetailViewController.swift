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
    @IBOutlet weak var favoriteStarButton: UIButton!
    @IBOutlet weak var yellowFavorite: UIButton!
    

    
    //the optional is a "failable" initializer so we can check if the image is nil (not there)
    var image = UIImage?()
    var nameText = String()
    var descText = String()
    var addressText = String()
    var location = CLLocation()
    var passedObject = PFObject(className: "Event")
    var currentUser = PFUser.currentUser()
    var favorited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil {
            var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
            
            let query = favoritesRelation?.query()
            
            query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    //checks if returns array contains the event; if it does, this button removes that relation. If not, it adds the relation
                    for object in objects! {
                        if object.objectId == self.passedObject.objectId {
                            self.favorited = true
                            self.yellowFavorite.hidden = false
                            self.favoriteStarButton.hidden = true
                            return
                        } else {
                            self.favorited = false
                            self.yellowFavorite.hidden = true
                            self.favoriteStarButton.hidden = false
                        }
                    }
                } else {
                    print("Error finding favorites")
                }
            })
        }
        
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
        if let userImageFile = self.passedObject["eventImage"] as? PFFile {
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
    
    @IBAction func starTapped(sender: AnyObject) {
        if yellowFavorite.hidden == true {
            print("White tapped")
            var relation = currentUser?.relationForKey("favoriteEvents")
            relation?.addObject(self.passedObject)
            self.currentUser?.saveInBackground()
            yellowFavorite.hidden = false
            favoriteStarButton.hidden = true
        }
    }
    
    @IBAction func yellowTapped(sender: AnyObject) {
        if favoriteStarButton.hidden == true {
            print("yellow tapped")
            var relation = currentUser?.relationForKey("favoriteEvents")
            relation?.removeObject(self.passedObject)
            self.currentUser?.saveInBackground()
            yellowFavorite.hidden = true
            favoriteStarButton.hidden = false
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
