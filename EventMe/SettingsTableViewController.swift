//
//  SettingsTableViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/24/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SettingsTableViewController: UITableViewController {
    
    var currentUser = PFUser.currentUser()
    var tField: UITextField!
    var errorCode: Int!

    @IBOutlet weak var emailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        
        if currentUser!.email == nil {
            self.emailImage.image = UIImage(named: "warning.png")
        } else {
            self.emailImage.image = UIImage(named: "okIcon.png")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func soundSwitch(sender: AnyObject) {
        
    }
    
    //actions are set here for each tapped static cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if(indexPath.row == 1) {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if currentUser!.email == nil {
                setUpAlert()
            } else {
                let emptyText = UIAlertView()
                emptyText.title = "You're good to go"
                emptyText.message = "You've already added an email to your account!"
                emptyText.addButtonWithTitle("OK")
                emptyText.show()
                return;
            }
        }
        
        
    }
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "exampe@domain.com"
        tField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        //do nothing; required method
    }
    
    func setUpAlert() {
        var alert = UIAlertController(title: "Enter email address", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            print("Done !!")
            print("Item : \(self.tField.text)")
            PFUser.requestPasswordResetForEmailInBackground(self.tField.text!, block: { (Bool, error: NSError?) -> Void in
                if let error = error {
                    
                   //sets the error code
                   self.errorCode = error.code
                   self.setUpTryAgain()
                }
            })
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func tryAgainFunc(alertView: UIAlertAction!) {
        setUpAlert()
    }
    
    func setUpTryAgain() {
        var errorMessage = ""
        
        if errorCode == 125 {
           errorMessage = "Invalid email address"
        } else if errorCode == 205 {
            errorMessage = "No user found with that email address"
        }
        
        var alert = UIAlertController(title: "Failed to reset password", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: tryAgainFunc))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        self.presentViewController(alert, animated: true) { () -> Void in
            //completion
        }
    }
}
