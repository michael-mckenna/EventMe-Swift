//
//  NewEventTableViewController.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/28/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse

class NewEventTableViewController: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    // send event to parse
    @IBAction func submitEvent(sender: UIBarButtonItem) {
        
        /* check that values have been updated before submission */
        
        // name, details, tags, date
        if EventNameTagsDetailsDateViewController.name.isEmpty || EventNameTagsDetailsDateViewController.details.isEmpty || EventNameTagsDetailsDateViewController.textFields.count == 0 ||
            EventNameTagsDetailsDateViewController.date.isEmpty {
                
            let alert = UIAlertController(title: nil, message: "You still have things to do!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                // ...
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // location
        if EventLocationViewController.eventLocation.coordinate.latitude == 0 ||
            EventLocationViewController.eventLocation.coordinate.longitude == 0 {
                let alert = UIAlertController(title: nil, message: "Please set a valid location!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    // ...
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                return
        }
        
        // set up event for submission
        let event = PFObject(className: "Event")
        
        event["eventName"] = EventNameTagsDetailsDateViewController.name
        event["eventDescription"] = EventNameTagsDetailsDateViewController.details
        event["eventDate"] = EventNameTagsDetailsDateViewController.date
        
        // getting tag data
        let length = EventNameTagsDetailsDateViewController.textFields.count
        for var i = 0; i < length; i++ {
            // TODO: update parse tag data
            print(EventNameTagsDetailsDateViewController.textFields[i].text)
        }
        
        // getting location data
        let location = EventLocationViewController.eventLocation
        let point = PFGeoPoint(location: location)
        event["eventLocation"] = point
        event["votes"] = 0
        
        // no image included
        if EventImageViewController.image == UIImage?() {
            print("IM here")
            let alert = UIAlertController(title: nil, message: "Are you sure you don't want to include an image?", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Yep!", style: .Default, handler: { (action) -> Void in
                
                /* Submit to parse without image */
                event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if(success) {
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        print("Successfully saved event\n")
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        // reset objects
                        EventNameTagsDetailsDateViewController.name = String()
                        EventNameTagsDetailsDateViewController.details = String()
                        EventNameTagsDetailsDateViewController.textFields = [UITextField]()
                        EventNameTagsDetailsDateViewController.date = String()
                        EventLocationViewController.eventLocation = CLLocation()
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Wait! Go Back!", style: .Default, handler: { (action) -> Void in
            
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        /* Submit to parse with image */
        print("IM STILL GOIN BITCH")
        // getting image data ready
        if let imageData = UIImagePNGRepresentation(EventImageViewController.image!) {
            let imageFile: PFFile!
            imageFile = PFFile(name: "image.png", data: imageData)
            event["eventImage"] = imageFile
        }
        
        
        event.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                print("Successfully saved event\n")
                self.navigationController?.popToRootViewControllerAnimated(true)
                
                // reset objects
                EventNameTagsDetailsDateViewController.name = String()
                EventNameTagsDetailsDateViewController.details = String()
                EventNameTagsDetailsDateViewController.textFields = [UITextField]()
                EventImageViewController.image = UIImage?()
                EventNameTagsDetailsDateViewController.date = String()
                EventLocationViewController.eventLocation = CLLocation()
            }
        }
        
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
