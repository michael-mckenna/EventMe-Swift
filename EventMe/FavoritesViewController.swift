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

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var currentUser = PFUser.currentUser()
    var eventsArray = [PFObject]()
    var refresher: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var managedObjectContext: NSManagedObjectContext? = nil
    
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
        
        searchFavorites()
    }
    
    func searchFavorites() {
        
        self.refresher.endRefreshing()
        progressBarDisplayer("Finding favorites", true)
        
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
    
    func refresh() {
       searchFavorites()
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
        
        return eventsArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellToReturn = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavoritesCustomCell
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
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if(currentUser != nil) {
                var favoritesRelation = currentUser?.relationForKey("favoriteEvents")
                favoritesRelation?.removeObject(eventsArray[indexPath.row])
                currentUser?.saveInBackground()
                eventsArray.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //taking elements from EventDetailViewController and putting them into DestinationViewController object
        if(segue.identifier == "favDetailsSegue") {
            if let destination = segue.destinationViewController as? EventDetailViewController {
                if let eventIndex = self.tableView.indexPathForSelectedRow {
                    print(eventIndex.row)
                    print(eventIndex)
                    var object = self.eventsArray[eventIndex.row]
                    print(object["eventName"] as! String)
                    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
