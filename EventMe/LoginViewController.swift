//
//  ViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/18/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
import ParseFacebookUtilsV4
import FBSDKCoreKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        username.delegate = self
        password.delegate = self
        
        //setting up facebook login button
        var facebookLogin = FBSDKLoginButton()
        //want this button to conform to this protocol
        facebookLogin.delegate = self
        facebookLogin.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLogin.frame = CGRectMake(20, 359, 335, 30)
        self.view.addSubview(facebookLogin)
        
        if((PFUser.currentUser()) != nil || FBSDKAccessToken.currentAccessToken() != nil) {
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
        } else {
            PFUser.logInWithUsernameInBackground(username!, password: password!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                    self.performSegueWithIdentifier("loginToFeed", sender: self)
                } else {
                    // The login failed. Check error to see why.
                }
            }
        }
    }
    

    public func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            print(error.localizedDescription)
            return
        } else {
          print("No error")
          self.performSegueWithIdentifier("loginToFeed", sender: self)
        }
        
    }

    public func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("user is logged out")
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

