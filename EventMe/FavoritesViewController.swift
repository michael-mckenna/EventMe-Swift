//
//  FavoritesViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/20/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import Parse
import UIKit

class FavoritesViewController: UIViewController {
    
    var currentUser = PFUser.currentUser()
    var eventsArray = [PFObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(currentUser != nil) {
            var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
            var query = favoritesRelation?.query()
            query!.addDescendingOrder("votes")
            query!.limit = 1000
            query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?)-> Void in
                if(error == nil) {
                    self.eventsArray = objects!
                    self.tableView.reloadData()
                } else {
                    //alert dialog
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return eventsArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        var object = eventsArray[indexPath.row]
        
        cell.textLabel?.text = object["eventName"] as! String
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        return indexPath
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            eventsArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //taking elements from EventDetailViewController and putting them into DestinationViewController object
        if(segue.identifier == "favDetailSegue") {
            if let destination = segue.destinationViewController as? EventDetailViewController {
                if let eventIndex = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                    var object = self.eventsArray[eventIndex.row]
                    
                    destination.nameText = object["eventName"] as! String
                    destination.descText = object["eventDescription"] as! String
                    
                    //breaking down coordinates from PFGeoPoint into a string address using CLGeocoder
                    var location = object["eventLocation"]
                    if location != nil {
                        var convLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        CLGeocoder().reverseGeocodeLocation(convLocation, completionHandler: { (placemarks, error) -> Void in
                            if error == nil {
                                if let p = placemarks?[0] {
                                    var subThoroughfare: String = ""
                                    if p.subThoroughfare != nil {
                                        subThoroughfare = p.subThoroughfare!
                                        //breaks down the different parts of an address. See documentation for each component
                                        destination.addressText = "\(subThoroughfare) \(p.thoroughfare!) \n \(p.locality!), \(p.administrativeArea!) \(p.postalCode!)"
                                    }
                                    
                                }
                            }
                        })
                    }
                    
                    //extracting image data from object
                    if let userImageFile = object["eventImage"] as? PFFile {
                        userImageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    destination.image = UIImage(data:imageData)
                                } else {
                                    print("There was no image")
                                }
                            }
                        }
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
