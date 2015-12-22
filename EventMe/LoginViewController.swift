//
//  ViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if((PFUser.currentUser()) != nil) {
            self.performSegueWithIdentifier("loginToFeed", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(sender: AnyObject) {
        let username = self.username.text
        let password = self.password.text
        
        PFUser.logInWithUsernameInBackground(username!, password: password!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.performSegueWithIdentifier("loginToFeed", sender: self)
            } else {
                // The login failed. Check error to see why.
                print("There was an error")
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    
    @IBAction func skip(sender: AnyObject) {
        self.performSegueWithIdentifier("loginToFeed", sender: self)
    }


}

