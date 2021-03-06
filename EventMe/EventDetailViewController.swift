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
import CoreData

class EventDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
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
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil {
            var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
   
            let query = favoritesRelation?.query()
            
            query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    print("no error")
                    //checks if returns array contains the event; if it does, this button removes that relation. If not, it adds the relation
                    if(objects!.count > 0) {
                    for object in objects! {
                        print("non empty array")
                        if object.objectId == self.passedObject.objectId {
                            print("favorite found")
                            self.yellowFavorite.hidden = false
                            self.favoriteStarButton.hidden = true
                            return
                        } else {
                            print("favorite not found")
                            self.yellowFavorite.hidden = true
                            self.favoriteStarButton.hidden = false
                        }
                    }
                    } else {
                        print("empty array")
                        self.yellowFavorite.hidden = true
                        self.favoriteStarButton.hidden = false
                    }
                } else {
                    print("Error finding favorites")
                }
            })
        } else {
            // setting up required core data components
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context : NSManagedObjectContext = appDel.managedObjectContext
            let request = NSFetchRequest(entityName: "Events")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "objectId = %@", self.passedObject.objectId!)
            do {
                let result = try context.executeFetchRequest(request)
                for value in result as! [NSManagedObject] {
                    if result.count > 0 {
                        if value.valueForKey("favorited") as! Bool == true {
                            print("favorite found")
                            self.yellowFavorite.hidden = false
                            self.favoriteStarButton.hidden = true
                            return
                        } else {
                            print("favorite not found")
                            self.yellowFavorite.hidden = true
                            self.favoriteStarButton.hidden = false
                        }
                    } 
                }
            } catch {
                print("error retrieving object from core data")
            }
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
            if currentUser != nil {
                print("White tapped")
                var relation = currentUser?.relationForKey("favoriteEvents")
                relation?.addObject(self.passedObject)
                self.currentUser?.saveInBackground()
                yellowFavorite.hidden = false
                favoriteStarButton.hidden = true
            } else {
                 print("White tapped")
                // setting up required core data components
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context : NSManagedObjectContext = appDel.managedObjectContext
                let request = NSFetchRequest(entityName: "Events")
                request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: "objectId = %@", self.passedObject.objectId!)
                do {
                    let result = try context.executeFetchRequest(request)
                    for value in result as! [NSManagedObject] {
                        //setting the value for the object in core data as favorited
                        value.setValue(true, forKey: "favorited")
                        do {
                            try context.save()
                            yellowFavorite.hidden = false
                            favoriteStarButton.hidden = true
                        } catch {
                            print("couldn't save core data")
                        }
                    }
                } catch {
                    print("error retrieving core data")
                }
                
            }
        }
    }
    
    @IBAction func yellowTapped(sender: AnyObject) {
        if currentUser != nil {
        if favoriteStarButton.hidden == true {
            print("yellow tapped")
            var relation = currentUser?.relationForKey("favoriteEvents")
            relation?.removeObject(self.passedObject)
            self.currentUser?.saveInBackground()
            yellowFavorite.hidden = true
            favoriteStarButton.hidden = false
            }
        } else {
        print("yellow tapped")
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "objectId = %@", self.passedObject.objectId!)
        do {
            let result = try context.executeFetchRequest(request)
            for value in result as! [NSManagedObject] {
                value.setValue(false, forKey: "favorited")
                do {
                    try context.save()
                    yellowFavorite.hidden = true
                    favoriteStarButton.hidden = false
                } catch {
                    print("couldn't save core data")
                }
            }
        } catch {
            print("error retrieving core data")
        }
    }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
