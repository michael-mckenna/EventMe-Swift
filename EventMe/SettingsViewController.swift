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

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("toLoginSegue", sender: self)
    }
    
}
