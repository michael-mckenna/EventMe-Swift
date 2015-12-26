//
//  FeedViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//


import UIKit
import Parse
import CoreLocation
import CoreData

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate  {
    
    @IBOutlet weak var eventItem: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    
    var query = PFQuery(className:"Event")
    var eventsArray = [PFObject]()
    var manager: CLLocationManager!
    var latitude = 0.0
    var longitude = 0.0
    var point = PFGeoPoint()
    var currentUser = PFUser.currentUser()
    var displayAble = true
    var refresher: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var managedObjectContext: NSManagedObjectContext? = nil
    
// make sure core data is synced with parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem.image = UIImage(named: "tabIcon.png")
        self.navigationController?.navigationBar.translucent = false
        
        //refresher to load events
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        //table view elements
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 112
        self.tableView.addSubview(refresher)
    
        //location manager initialization
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            if results.count == 0 {
                let newObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Events", inManagedObjectContext: context)
                newObject.setValue("randomObjToFillArray", forKey: "objectId")
            }
        } catch {
            
        }

        
    }
    
    func refresh() {
        displayAble = true
        manager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
      
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print(locations)
        
        //userLocation - there is no need for casting, because we are now using CLLocation object

        let userLocation:CLLocation = locations[0]
        
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        
        point.latitude = latitude
        point.longitude = longitude
        
        if(manager.location != nil && displayAble == true) {
            self.manager.stopUpdatingLocation()
            displayAble = false
            searchEvents()
        }
        
    }
    
    func searchEvents() {
        progressBarDisplayer("Searching Events", true)
        
        query.addDescendingOrder("votes")
        query.whereKey("eventLocation", nearGeoPoint: point, withinMiles: 5)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                // There was an error
                print("error")
            } else {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.eventsArray = objects!
                
                // setting up required core data components
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context : NSManagedObjectContext = appDel.managedObjectContext
                let request = NSFetchRequest(entityName: "Events")
                request.returnsObjectsAsFaults = false
                
                for var i = 0; i < self.eventsArray.count; ++i {
                    request.predicate = NSPredicate(format: "objectId = %@", self.eventsArray[i].objectId!)
                    
                    do {
                        let results = try context.executeFetchRequest(request)
                        if results.count == 0 {
                            
                            //if there is no core data that has the event's id, we make one
                            let newObject = NSEntityDescription.insertNewObjectForEntityForName("Events", inManagedObjectContext: context)
                            newObject.setValue(self.eventsArray[i].objectId, forKey: "objectId")
                            newObject.setValue(false, forKey: "upVoted")
                            newObject.setValue(false, forKey: "downVoted")
                            newObject.setValue(false, forKey: "favorited")
                            print("objectId")
                            do {
                                try context.save()
                            } catch {
                                print("Couldn't save to core data")
                            }

                        }
                    } catch {
                        print("something went wrong")
                    }
                }
                
                self.activityIndicator.stopAnimating()
                self.messageFrame.removeFromSuperview()
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }
    }
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 100, width: 200, height: 50))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
       
        let cellToReturn = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedCustomCell
        let object = eventsArray[indexPath.row]
        
        cellToReturn.accessoryType = UITableViewCellAccessoryType.None
        cellToReturn.nameLabel.text = (object["eventName"] as! String)
        cellToReturn.votesLabel.text = String(object["votes"])
        
        //upVote functionality
        cellToReturn.upArrow.tag = indexPath.row
        cellToReturn.upArrow.addTarget(self, action: "upVote:", forControlEvents: .TouchUpInside)

        //downvote functionality
        cellToReturn.downArrow.tag = indexPath.row
        cellToReturn.downArrow.addTarget(self, action: "downVote:", forControlEvents: .TouchUpInside)
        
        return cellToReturn
    }
    
    func upVote(sender: AnyObject) {
        
        let button: UIButton = sender as! UIButton
        let object = self.eventsArray[button.tag]
        
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "objectId = %@", object.objectId!)
        
        do {
            let result = try context.executeFetchRequest(request)
            for value in result as! [NSManagedObject] {
                
                //check if there is a nil value
                if value.valueForKey("upVoted") as? Bool != nil {
                    //check if the bool value is false
                    if value.valueForKey("upVoted") as! Bool == false {
                        
                    if value.valueForKey("downVoted") as? Bool != nil {
                        if value.valueForKey("downVoted") as! Bool == true {
                            object["votes"] = object["votes"] as! Int + 2
                        } else {
                           object["votes"] = object["votes"] as! Int + 1
                        }
                    }
                        
                    value.setValue(false, forKey: "downVoted")
                    value.setValue(true, forKey: "upVoted")
                    do {
                        try context.save()
                    } catch {
                        print("Couldn't save changes")
                    }
                        
                    object.saveInBackground()
    
                    let indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    } else {
                        value.setValue(false, forKey: "upVoted")
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save changes")
                        }
                        
                        object["votes"] = object["votes"] as! Int - 1
                        object.saveInBackground()
                        
                        let indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    }
                }
            }
        } catch {
            print("Something went wrong")
        }

    }
    
    func downVote(sender: AnyObject) {
        
        var button: UIButton = sender as! UIButton
        var object = self.eventsArray[button.tag]
        
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "objectId = %@", object.objectId!)
        
        do {
            let result = try context.executeFetchRequest(request)
            for value in result as! [NSManagedObject] {
                if value.valueForKey("downVoted") as? Bool != nil {
                    if value.valueForKey("downVoted") as! Bool == false {
                    
                    // if the user already upvoted, we want to make down vote decrease the vote count by 2 (so it's one less from the original value)
                    if value.valueForKey("upVoted") as? Bool != nil {
                        if value.valueForKey("upVoted") as! Bool == true {
                            object["votes"] = object["votes"] as! Int - 2
                        } else {
                            object["votes"] = object["votes"] as! Int - 1
                        }
                    }
                        
                    value.setValue(true, forKey: "downVoted")
                    value.setValue(false, forKey: "upVoted")
            
                    do {
                        try context.save()
                    } catch {
                        print("Error saving changes")
                    }
                        
                    object.saveInBackground()
                    
                    var indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    } else {
                        value.setValue(false, forKey: "downVoted")
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save changes")
                        }
                        
                        object["votes"] = object["votes"] as! Int + 1
                        object.saveInBackground()
                        
                        let indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    }

                }
            }
        } catch {
            print("Something went wrong")
        }
        
    }
    
     func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        
        return indexPath
    }

    //deletes row. Probably won't implement this in final version
    /*func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            eventsArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }*/
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        self.performSegueWithIdentifier("createEventSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //taking elements from EventDetailViewController and putting them into DestinationViewController object
        if(segue.identifier == "detailSegue") {
            if let destination = segue.destinationViewController as? EventDetailViewController {
                if let eventIndex = self.tableView.indexPathForSelectedRow {
                    var object = self.eventsArray[eventIndex.row]

                    destination.nameText = object["eventName"] as! String
                    destination.descText = object["eventDescription"] as! String
                    
                    //breaking down coordinates from PFGeoPoint into a string address using CLGeocoder
                    var location = object["eventLocation"]
                    var convLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    destination.location = convLocation
                    
                    //extracting image data from object
                    destination.passedObject = object
                }
            }
        }
    }

    
}

