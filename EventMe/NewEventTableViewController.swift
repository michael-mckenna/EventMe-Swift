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

    @IBAction func submitEvent(sender: UIBarButtonItem) {
        
        /* Submit to parse */
        let event = PFObject(className: "Event")

        event["eventName"] = EventNameTagsDetailsDateViewController.name
        event["eventDescription"] = EventNameTagsDetailsDateViewController.details
        event["eventDate"] = EventNameTagsDetailsDateViewController.date
        
        // getting tag data
        let length = EventNameTagsDetailsDateViewController.textFields.count
        for var i = 0; i < length; i++ {
            // TODO: update the tags
            let tagName = EventNameTagsDetailsDateViewController.textFields[i].text
        }
        
        // getting location data
        let location = EventLocationViewController.eventLocation
        let point = PFGeoPoint(location: location)
        event["eventLocation"] = point
        event["votes"] = 0
        
        //getting image data ready
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
