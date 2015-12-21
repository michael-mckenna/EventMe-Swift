//
//  EventDetailViewController.swift
//  EventMe
//
//  Created by Michael McKenna on 12/20/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MapKit

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var nameText = String()
    //the optional is a "failable" initializer so we can check if the image is nil (not there)
    var image = UIImage?()
    var descText = String()
    var addressText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.eventName.text = nameText
        if(image != nil) {
            self.eventImage.image = image
        }
        self.descriptionLabel.text = addressText
        self.addressLabel.text = addressText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
