//
//  SignUpViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signUp(sender: AnyObject) {
        var user = PFUser()
        user.username = self.username.text
        user.password = self.password.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
            } else {
                // Hooray! Let them use the app now.
                print("Successful sign up")
                self.performSegueWithIdentifier("signUpToFeed", sender: self)
            }
        }
    }
    
}

