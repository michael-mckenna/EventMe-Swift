//
//  SignUpViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate = self
        password.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signUp(sender: AnyObject) {
        var user = PFUser()
        user.username = self.username.text
        user.password = self.password.text
        
        if self.username.text!.isEmpty || self.password.text!.isEmpty {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "One or more fields were left blank!"
            alert.addButtonWithTitle("OK")
            alert.show()
            return
        }
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "There was an unknown error. Please try again"
                alert.addButtonWithTitle("OK")
                alert.show()
                return
                
            } else {
                // Hooray! Let them use the app now.
                print("Successful sign up")
                self.performSegueWithIdentifier("signUpToFeed", sender: self)
            }
        }
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

