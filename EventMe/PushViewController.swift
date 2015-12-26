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

class PushViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var currentUser = PFUser.currentUser()
    var tagObjectArray = [PFObject]()
    var selectedCells = [Bool]()
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if pushSwitch.on {
            self.tableView.hidden = false
            var query = PFQuery(className: "Tag")
            query.addAscendingOrder("tagName")
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.tagObjectArray = objects!
                    for var i = 0; i < self.tagObjectArray.count; ++i {
                        self.selectedCells.append(false)
                    }
                }
            })
            
        } else {
            self.tableView.hidden = true
        
        }
        
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return tagObjectArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell: TagsCustomCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? TagsCustomCell else {
            fatalError(("unexpected cell dequeued from tableView"))
        }
        
        var object = tagObjectArray[indexPath.row]
        
        cell.tagName.text = object["tagName"] as! String
        
        if cell.selected
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        

        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        if cell!.selected
        {
            cell!.selected = false
            if cell!.accessoryType == UITableViewCellAccessoryType.None
            {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else
            {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }


    
    @IBAction func save(sender: AnyObject) {
        for var i = 0; i < tagObjectArray.count; ++i {
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 1))
            if(cell?.selected == true) {
                //save preffed tagname in core data
                // setting up required core data components
                var object = self.tagObjectArray[i]
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context : NSManagedObjectContext = appDel.managedObjectContext
                let request = NSFetchRequest(entityName: "SavedTags")
                request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: "tagName = %@", object["tagName"] as! String)
                do {
                     print("got here")
                    let results = try context.executeFetchRequest(request)
                    if results.count == 0 {
                         print("got here")
                    let newObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("SavedTags", inManagedObjectContext: context)
                        newObject.setValue(object["tagName"] as! String, forKey: "tagName")
                        //TODO: save context!
                        print("Saved tag \(object["tagName"] as! String)")
                    }
                } catch {
                    print("Error searching core data")
                }
            } else {
                print("No selected")
            }
        }
    }

    @IBAction func pushSwitch(sender: AnyObject) {
        if pushSwitch.on {
            self.tableView.hidden = false
            
            var query = PFQuery(className: "Tag")
            query.addAscendingOrder("tagName")
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.tagObjectArray = objects!
                    self.tableView.reloadData()
                } else {
                    print("Error")
                }
            })
        } else {
            self.tableView.hidden = true
        }
    }
    
    
    
    
   
}
