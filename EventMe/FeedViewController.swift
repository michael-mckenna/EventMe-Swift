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

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
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
        
    }
    
    func refresh() {
        displayAble = true
        manager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        //searchEvents()

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
                self.activityIndicator.stopAnimating()
                self.messageFrame.removeFromSuperview()
                self.eventsArray = objects!
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }
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
        var object = eventsArray[indexPath.row]
        
        cellToReturn.accessoryType = UITableViewCellAccessoryType.None
        cellToReturn.nameLabel.text = object["eventName"] as! String
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
        var button: UIButton = sender as! UIButton
        var object = self.eventsArray[button.tag]
        object["votes"] = object["votes"] as! Int + 1
        
        var indexPath = NSIndexPath(forRow: button.tag, inSection:0)
        object.saveInBackground()
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    func downVote(sender: AnyObject) {
        var button: UIButton = sender as! UIButton
        var object = self.eventsArray[button.tag]
        object["votes"] = object["votes"] as! Int - 1
        
        var indexPath = NSIndexPath(forRow: button.tag, inSection: 0)
        object.saveInBackground()
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        
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
                    destination.userImageObject = object
                }
            }
        }
    }

    
}

