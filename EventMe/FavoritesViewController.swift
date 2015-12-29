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
import CoreData
import CoreLocation
import AVFoundation

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var currentUser = PFUser.currentUser()
    var eventsArray = [PFObject]()
    var coreArray = [PFObject]()
    var point = PFGeoPoint()
    var refresher: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var manager: CLLocationManager!
    var latitude = 0.0
    var longitude = 0.0
    var managedObjectContext: NSManagedObjectContext? = nil
    var displayAble = false
    var voteObject = PFObject(className: "Event")
    var showProgressFrame = true
    var player: AVAudioPlayer!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refresher to load events
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        //table view elements
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 112
        self.tableView.addSubview(refresher)
        
        if currentUser != nil {
            searchFavorites()
        } else {
            print("nil user")
            //location manager initialization
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    self.point = geoPoint!
                    self.searchEvents()
                    print("got here")
                }
            }
        }
    }
    
    func searchFavorites() {
        
        self.refresher.endRefreshing()
        if showProgressFrame {
            progressBarDisplayer("Finding favorites", true)
        }
        
        if(currentUser != nil) {
            var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
            var query = favoritesRelation?.query()
            query!.addDescendingOrder("votes")
            query!.limit = 1000
            query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?)-> Void in
                if(error == nil) {
                    self.eventsArray = objects!
                    self.tableView.reloadData()
                    self.messageFrame.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                } else {
                    //alert dialog
                }
            }
        }
        
    }
        
    func searchEvents() {
        
        if showProgressFrame {
            progressBarDisplayer("Finding favorites", true)
        }

        var query = PFQuery(className: "Event")
        query.addDescendingOrder("votes")
        query.whereKey("eventLocation", nearGeoPoint: point, withinMiles: 5)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                // There was an error
                print("error")
            } else {
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.coreArray.removeAll()
                self.eventsArray = objects!
                
                // setting up required core data components
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context : NSManagedObjectContext = appDel.managedObjectContext
                let request = NSFetchRequest(entityName: "Events")
                request.returnsObjectsAsFaults = false
                //returns all core events that have the value of favorited as true
                request.predicate = NSPredicate(format: "favorited = %@", true)
                do {
                    let result = try context.executeFetchRequest(request)
                    if result.count > 0 {
                        for value in result as! [NSManagedObject] {
                            for var i = 0; i < self.eventsArray.count; ++i {
                                // the value for the event is true, so now we are comparing that to the events array to find which object it is that is favorited.
                                // we have to do this because we cannot save a PFObject in core data - only its components
                                if value.valueForKey("objectId") as! String == self.eventsArray[i].objectId {
                                    self.coreArray.append(self.eventsArray[i])
                                }
                            }
                        }
                    }
                } catch {
                    print("failed to retrieve core data")
                }
            }
                self.activityIndicator.stopAnimating()
                self.messageFrame.removeFromSuperview()
                self.tableView.reloadData()
                self.refresher.endRefreshing()
        }
    }
    
    func refresh() {
        if currentUser != nil {
            searchFavorites()
            
        } else {
            searchEvents()
        }
        //refresh audio
        let audioPath = NSBundle.mainBundle().pathForResource("Blop", ofType: "wav")!
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            player.play()
        } catch {
            print("Error making player play")
        }
        
        showProgressFrame = false
    }
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        
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
    

    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        if(currentUser != nil) {
        return eventsArray.count
        } else {
            return coreArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
     
        let cellToReturn = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavoritesCustomCell
        if currentUser != nil {
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
        } else {
            let object = coreArray[indexPath.row]
            cellToReturn.accessoryType = UITableViewCellAccessoryType.None
            cellToReturn.nameLabel.text = (object["eventName"] as! String)
            cellToReturn.votesLabel.text = String(object["votes"])
            
            //upVote functionality
            cellToReturn.upArrow.tag = indexPath.row
            cellToReturn.upArrow.addTarget(self, action: "upVote:", forControlEvents: .TouchUpInside)
            
            //downvote functionality
            cellToReturn.downArrow.tag = indexPath.row
            cellToReturn.downArrow.addTarget(self, action: "downVote:", forControlEvents: .TouchUpInside)
        }
        
        return cellToReturn
    }
    
    func upVote(sender: AnyObject) {
        
        let button: UIButton = sender as! UIButton
        if currentUser != nil {
            self.voteObject = self.eventsArray[button.tag]
        } else {
            self.voteObject = self.coreArray[button.tag]
        }
        
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "objectId = %@", self.voteObject.objectId!)
        
        do {
            let result = try context.executeFetchRequest(request)
            for value in result as! [NSManagedObject] {
                
                //check if there is a nil value
                if value.valueForKey("upVoted") as? Bool != nil {
                    //check if the bool value is false
                    if value.valueForKey("upVoted") as! Bool == false {
                        
                        if value.valueForKey("downVoted") as? Bool != nil {
                            if value.valueForKey("downVoted") as! Bool == true {
                                self.voteObject["votes"] = self.voteObject["votes"] as! Int + 2
                            } else {
                                self.voteObject["votes"] = self.voteObject["votes"] as! Int + 1
                            }
                        }
                        
                        value.setValue(false, forKey: "downVoted")
                        value.setValue(true, forKey: "upVoted")
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save changes")
                        }
                        
                        self.voteObject.saveInBackground()
                        
                        let indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    } else {
                        value.setValue(false, forKey: "upVoted")
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save changes")
                        }
                        
                        self.voteObject["votes"] = self.voteObject["votes"] as! Int - 1
                        self.voteObject.saveInBackground()
                        
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
        if currentUser != nil {
            self.voteObject = self.eventsArray[button.tag]
        } else {
            self.voteObject = self.coreArray[button.tag]
        }
        
        // setting up required core data components
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Events")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "objectId = %@", self.voteObject.objectId!)
        
        do {
            let result = try context.executeFetchRequest(request)
            for value in result as! [NSManagedObject] {
                if value.valueForKey("downVoted") as? Bool != nil {
                    if value.valueForKey("downVoted") as! Bool == false {
                        
                        // if the user already upvoted, we want to make down vote decrease the vote count by 2 (so it's one less from the original value)
                        if value.valueForKey("upVoted") as? Bool != nil {
                            if value.valueForKey("upVoted") as! Bool == true {
                                self.voteObject["votes"] = self.voteObject["votes"] as! Int - 2
                            } else {
                                self.voteObject["votes"] = self.voteObject["votes"] as! Int - 1
                            }
                        }
                        
                        value.setValue(true, forKey: "downVoted")
                        value.setValue(false, forKey: "upVoted")
                        
                        do {
                            try context.save()
                        } catch {
                            print("Error saving changes")
                        }
                        
                        self.voteObject.saveInBackground()
                        
                        var indexPath = NSIndexPath(forRow: button.tag, inSection:0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    } else {
                        value.setValue(false, forKey: "downVoted")
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save changes")
                        }
                        
                        self.voteObject["votes"] = self.voteObject["votes"] as! Int + 1
                        self.voteObject.saveInBackground()
                        
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
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if(currentUser != nil) {
                var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
                favoritesRelation?.removeObject(eventsArray[indexPath.row])
                currentUser?.saveInBackground()
                eventsArray.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            } else {
                //make favorited key false for core data
                // setting up required core data components
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context : NSManagedObjectContext = appDel.managedObjectContext
                let request = NSFetchRequest(entityName: "Events")
                request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: "objectId = %@", self.coreArray[indexPath.row].objectId!)
                
                do {
                    let result = try context.executeFetchRequest(request)
                    for value in result as! [NSManagedObject] {
                        value.setValue(false, forKey: "favorited")
                    }
                    do {
                        try context.save()
                        coreArray.removeAtIndex(indexPath.row)
                        self.tableView.reloadData()
                    } catch {
                        print("couldn't save that change")
                    }
                } catch {
                    print("faild to retrieve core data")
                }
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //taking elements from EventDetailViewController and putting them into DestinationViewController object
        if(segue.identifier == "favDetailsSegue") {
            if let destination = segue.destinationViewController as? EventDetailViewController {
                if let eventIndex = self.tableView.indexPathForSelectedRow {
                    
                    if currentUser != nil {
                    var object = self.eventsArray[eventIndex.row]
                    
                    destination.nameText = object["eventName"] as! String
                    destination.descText = object["eventDescription"] as! String
                    
                    //breaking down coordinates from PFGeoPoint into a string address using CLGeocoder
                    var location = object["eventLocation"]
                    var convLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    destination.location = convLocation
                    
                    //copying object
                    destination.passedObject = object
                        
                    } else {
                        var object = self.coreArray[eventIndex.row]
                        
                        destination.nameText = object["eventName"] as! String
                        destination.descText = object["eventDescription"] as! String
                        
                        //breaking down coordinates from PFGeoPoint into a string address using CLGeocoder
                        var location = object["eventLocation"]
                        var convLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        destination.location = convLocation
                        
                        //copying object
                        destination.passedObject = object
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
