//
//  SettingsViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/21/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FBSDKLoginKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var logButton: UIButton!
    
    var currentUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUser != nil || FBSDKAccessToken.currentAccessToken() != nil {
            logButton.setTitle("Log Out", forState: .Normal)
        } else if currentUser == nil || FBSDKAccessToken.currentAccessToken() == nil {
            logButton.setTitle("Log In", forState: .Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(sender: AnyObject) {
        if currentUser != nil {
            PFUser.logOut()
            self.performSegueWithIdentifier("toLoginSegue", sender: self)
        } else if FBSDKAccessToken.currentAccessToken() != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            self.performSegueWithIdentifier("toLoginSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("toLoginSegue", sender: self)
        }
        
    }
    
}
