//
//  ViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        username.delegate = self
        password.delegate = self
        
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

        // catch for empty text fields
        if self.username.text!.isEmpty || self.password.text!.isEmpty {
            let emptyText = UIAlertView()
            emptyText.title = "Error"
            emptyText.message = "Username or Password is blank!"
            emptyText.addButtonWithTitle("OK")
            emptyText.show()
            return;
        }
        
        PFUser.logInWithUsernameInBackground(username!, password: password!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.performSegueWithIdentifier("loginToFeed", sender: self)
            } else {
                // The login failed. Check error to see why.
                let emptyText = UIAlertView()
                emptyText.title = "Error"
                emptyText.message = "Username or Password is Invalid"
                emptyText.addButtonWithTitle("OK")
                emptyText.show()
                return;
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    
    @IBAction func skip(sender: AnyObject) {
        self.performSegueWithIdentifier("loginToFeed", sender: self)
    }

    
    //closes keyboard when user touches outside of the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //closes keyboard when user taps the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed.
    {
        textField.resignFirstResponder()
        return true;
    }

}

