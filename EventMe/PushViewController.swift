//
//  PushViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/24/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData

class PushViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var currentUser = PFUser.currentUser()
    var tagObjectArray = [String]()
    var selectedCells = [Bool]()
    var keepFood = false
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var searchInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the state of the switch
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Notifications")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            if results.count == 0 {
                let newObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Notifications", inManagedObjectContext: context)
                newObject.setValue(false, forKey: "turnedOn")
                do {
                    try context.save()
                } catch {
                    print("Failed to save")
                }
            } else {
                for value in results as! [NSManagedObject] {
                    if value.valueForKey("turnedOn") as! Bool {
                        self.pushSwitch.on = true
                    } else {
                        self.pushSwitch.on = false
                    }
                }
            }
        } catch {
            print("failed to fetch core data")
        }
        
        //handling the entity for the user's choice to keep the default tag
        let foodRequest = NSFetchRequest(entityName: "FoodDeleted")
        foodRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(foodRequest)
            if results.count == 0 {
                let newObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("FoodDeleted", inManagedObjectContext: context)
                newObject.setValue(true, forKey: "keepDeleted")
                do {
                    try context.save()
                } catch {
                    print("Failed to initialized deleted attribute")
                }
            } else {
                for value in results as! [NSManagedObject] {
                    if value.valueForKey("keepDeleted") as! Bool == true {
                        keepFood = true
                    } else {
                        keepFood = false
                    }
                }
            }
        } catch {
            print("Failed to fetch core data for FoodDeleted")
        }
        
        //filling table view with saved tags; defaults to a single one for "#food"
        let newRequest = NSFetchRequest(entityName: "SavedTags")
        newRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(newRequest)
            if results.count > 0 {
                for value in results as! [NSManagedObject] {
                    tagObjectArray.append(value.valueForKey("tagName") as! String)
                }
            } else if results.count == 0 {
                
                //check if the user deleted the #food notifications preference
                if keepFood {
                    newRequest.predicate = NSPredicate(format: "tagName = %@", "#food")
                    do{
                        //adding #food into core data if it hasn't been added already
                        let newResults = try context.executeFetchRequest(newRequest)
                        if newResults.count == 0 {
                            let addTag: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("SavedTags", inManagedObjectContext: context)
                            addTag.setValue("#food", forKey: "tagName")
                            do {
                                try context.save()
                            } catch {
                                print("failed to save #food")
                            }
                            tagObjectArray.append("#food")
                        } else {
                            tagObjectArray.append("#food")
                        }
                    }
                }
            }
        } catch {
            print("Error fetching core data")
        }
        
        //query for all parse tags
        let query = PFQuery()
        //
     
    }
    
    @available(iOS 2.0, *)
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tagObjectArray.count
    }

    @available(iOS 2.0, *)
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cellToReturn = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TagsCustomCell
        
        return cellToReturn
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func save(sender: AnyObject) {
        //save selection from search
        //have pop up saying "You added '#blah' to your notifications preferences
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    

    @IBAction func pushSwitch(sender: AnyObject) {
        
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context : NSManagedObjectContext = appDel.managedObjectContext
            let request = NSFetchRequest(entityName: "Notifications")
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.executeFetchRequest(request)
                for value in results as! [NSManagedObject] {
                    if self.pushSwitch.on {
                        value.setValue(true, forKey: "turnedOn")
                    } else {
                        value.setValue(false, forKey: "turnedOn")
                    }
                }
            }catch {
                print("failed to fetch core data")
            }

    }
    
    @IBAction func addTag(sender: AnyObject) {
        
    }
    
    
    
   
}
