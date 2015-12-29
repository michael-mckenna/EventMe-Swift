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
    var errorCode: Int = 0

    @IBOutlet weak var emailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        
        if currentUser != nil {
            if currentUser!.email == nil {
                self.emailImage.image = UIImage(named: "warning.png")
            } else {
                self.emailImage.hidden = true
            }
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
            if currentUser != nil {
            if currentUser!.email == nil {
                let emptyText = UIAlertView()
                emptyText.title = "Cannot reset password"
                emptyText.message = "You need to first set up an email"
                emptyText.addButtonWithTitle("OK")
                emptyText.show()
                return;
            } else {
                setUpAlert()
             }
            }
        } else if indexPath.row == 2 {
            if currentUser != nil {
                setUpEmailAlert()
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
    
    
    func alertEmailFailed() {
        var errorMessage = ""
        
        //didn't enter an eligible email address
        if errorCode == 125 {
            errorMessage = "Invalid email address"
            //no user's have the entered email address
        } else {
            errorMessage = "different error"
        }
        var alert = UIAlertController(title: "Failed to add email address", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler:verifyEmail))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        self.presentViewController(alert, animated: true) { () -> Void in
            //completion
        }
    }

    func verifyEmail(alertView: UIAlertAction!) {
        setUpEmailAlert()
    }

    func setUpEmailAlert() {
        var alert = UIAlertController(title: "Enter email address", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Verify", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            print("Done !!")
            print("Item : \(self.tField.text)")
            
            //set up user email
            self.currentUser!.email = self.tField.text
            self.currentUser?.saveInBackgroundWithBlock({ (succeeded, error: NSError?) -> Void in
                 if error == nil {
                    // User needs to verify email address before continuing
                    let alert = UIAlertView()
                    alert.title = "Verify email address"
                    alert.message = "Please check your email for the verification link"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                } else {
                    self.alertEmailFailed()
                }
            })
            
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func setUpTryAgain() {
        var errorMessage = ""
        
        //didn't enter an eligible email address
        if errorCode == 125 {
           errorMessage = "Invalid email address"
        //no user's have the entered email address
        } else if errorCode == 205 {
            errorMessage = "Please first link an email with your account"
        }
        
        var alert = UIAlertController(title: "Failed to reset password", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: tryAgainFunc))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        self.presentViewController(alert, animated: true) { () -> Void in
            //completion
        }
    }
}
