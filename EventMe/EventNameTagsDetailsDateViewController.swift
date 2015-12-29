//
//  EventNameTagsDetailsDateViewController.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/26/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit

class EventNameTagsDetailsDateViewController: UIViewController {
    /* name vars */
    @IBOutlet weak var eventName: UITextField!
    static var name = String()
    
    /* detail vars */
    @IBOutlet weak var eventDetails: UITextView! // details
    static var details = String()
    
    /* tag vars */
    @IBOutlet weak var eventTags: UITextField!
    @IBOutlet weak var anothaOneButton: UIButton!
    static var textFields = [UITextField]()
    
    /* Date Vars */
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var formattedDate: UILabel!
    static var date = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // handles keyboard dismissal
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        // formats default selected date
        if (self.formattedDate != nil) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eee, LLL dd, yyyy h:mm a"
            
            let strDate = dateFormatter.stringFromDate(eventDate.date)
            self.formattedDate.text = strDate
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /* SUBMIT METHODS */
    
    @IBAction func submitName(sender: AnyObject) {
        if self.eventName.text!.isEmpty {
            let alert = UIAlertController(title: nil, message: "You still need to add a Name!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                // ...
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        EventNameTagsDetailsDateViewController.name = self.eventName.text!
        
        // go back to create event menu
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func submitDetails(sender: AnyObject) {
        if self.eventDetails.text!.isEmpty {
            let alert = UIAlertController(title: nil, message: "You haven't added a description!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                // ...
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        EventNameTagsDetailsDateViewController.details = self.eventDetails.text!
        
        // go back to create event menu
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func submitTags(sender: AnyObject) {
        EventNameTagsDetailsDateViewController.textFields.append(self.eventTags)
        
        // go back to create event menu
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func submitDate(sender: AnyObject) {
        EventNameTagsDetailsDateViewController.date = self.formattedDate.text!
        navigationController?.popViewControllerAnimated(true)
    }

    
    /* Functions */
    
    // updates the date picker
    @IBAction func datePickerChanged(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "eee, LLL dd, yyyy hh:mm a"
        
        let strDate = dateFormatter.stringFromDate(eventDate.date)
        formattedDate.text = strDate
    }
    
    
    // adds another text field
    @IBAction func anothaOne(sender: AnyObject) {
        let x = anothaOneButton.frame.origin.x
        let y = anothaOneButton.frame.origin.y
        
        if (y > 500) {
            let alert = UIAlertController(title: nil, message: "Maximum number of tags already added!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                // ...
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let textField = UITextField(frame: CGRectMake(x, y - 50 + 30 + 5, 150, 30))
        textField.textAlignment = NSTextAlignment.Center
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.font = UIFont (name: "Avenir Next", size: 14)
        textField.placeholder = "hashTag"
        
        let label = UILabel(frame: CGRectMake(x + 5, y - 50 + 30 + 5 + 4, 10, 20))
        label.textAlignment = NSTextAlignment.Center
        label.text = "#"
        
        var frame = anothaOneButton.frame
        frame.origin.x = x//pass the cordinate which you want
        frame.origin.y = y + 30 + 5 //pass the cordinate which you want
        anothaOneButton.frame = frame
        
        self.view.addSubview(textField)
        self.view.addSubview(label)
        EventNameTagsDetailsDateViewController.textFields.append(textField)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
