//
//  EventImageViewController.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/26/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit

class EventImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var image = UIImage?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up the image picker
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
    }

    @IBAction func loadImage(sender: UIButton) {
        
        let alert = UIAlertController(title: "Photo Source", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo", style: .Default, handler: { (action) -> Void in
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Library", style: .Default, handler: { (action) -> Void in
            
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            //do nothing
        }))
        self.presentViewController(alert, animated: true, completion: nil)
   
    }
    
    //function called once a photo is taken/chosen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.imageView.image = resizeImage(self.image!, newWidth: 200)
        self.image = self.imageView.image
        //self.imageView.contentMode = .ScaleAspectFit
    }
    
    //function called when the user cancels photo picking
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alrightPresssed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
