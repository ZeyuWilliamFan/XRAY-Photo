//
//  XrayImageViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/14.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class XrayImageViewController: UIViewController, EditNotesTableViewControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var xrayImageView: UIImageView!
    
    var photo: Photo!
    
    var imageShowing: UIImage?
    
    var date = ""
    var doctorname = ""
    var bodypart = ""
    var notes = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("\(date) \(doctorname) \(bodypart) \(notes)")
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        self.navigationController?.toolbar.barTintColor = nil

        
        self.view.backgroundColor = UIColor.darkGrayColor()

        
        xrayImageView.image = imageShowing
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("toggleToUnHideBar:"))
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)
        
//        // Create the constraints and add them to a Array
//        var constraints = [AnyObject]()
//        
//        // This constraint centers the imageView Horizontally in the screen
//        constraints.append(NSLayoutConstraint(item: xrayImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
//        
//        // Now we need to put the imageView at the top margin of the view
//        constraints.append(NSLayoutConstraint(item: xrayImageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: 0.0))
//        
//        // You should also set some constraint about the height of the imageView
//        // or attach it to some item placed right under it in the view such as the
//        // BottomMargin of the parent view or another object's Top attribute.
//        // As example, I set the height to 500.
//        constraints.append(NSLayoutConstraint(item: xrayImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 500.0))
//        
//        // The next line is to activate the constraints saved in the array
//        NSLayoutConstraint.activateConstraints(constraints)
//        
 
    }

    func toggleToUnHideBar(gestureRecognizer: UIGestureRecognizer) {
        if self.view.backgroundColor == UIColor.darkGrayColor() {
            self.view.backgroundColor == UIColor.lightGrayColor()
        }
        else {
            self.view.backgroundColor == UIColor.darkGrayColor()
        }
        self.navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        self.navigationController?.setToolbarHidden(navigationController?.toolbarHidden == false, animated: true)
    }

    @IBAction func ActionMenu() {
        showActionMenu()
    }
    
    func showActionMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let EditAction = UIAlertAction(title: "Edit Notes", style: .Default,
            handler: {_ in self.performSegueWithIdentifier("EditNotes", sender: nil)})
        
        alertController.addAction(EditAction)
        
        let EmailAction = UIAlertAction(title: "Send via Email", style: .Default, handler:  {_ in self.sendEmail()})
        alertController.addAction(EmailAction)
        
        let AnonymizeAction = UIAlertAction(title: "Anonymize", style: .Default, handler: nil)
        alertController.addAction(AnonymizeAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject(NSLocalizedString("Xray Photos", comment: "Email subject"))
            controller.setToRecipients(["aaa@bbb.com"])
            
            var image: UIImage?
            var emailbody = "This is my Xray Photo along with the details that I want to show you.\n"
            let filePath = photo.photoPath
            println("File path loaded.")
            
            if let fileData = NSData(contentsOfFile: filePath) {
                println("File data loaded.")
                controller.addAttachmentData(fileData, mimeType: "image/jpeg",
                    fileName: "Photo-\(photo.photoID!.integerValue)")
            }
            emailbody += "\n"
            emailbody += "\n"
            emailbody += "Date: \(date) \n"
            emailbody += "Doctor: \(doctorname) \n"
            emailbody += "Body part: \(bodypart) \n"
            emailbody += "Notes: \(notes) \n"
            
            image = photo.photoImage
            controller.setMessageBody(emailbody, isHTML: false)
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    func returnEmailStringBase64EncodedImage(image:UIImage) -> String {
        let imgData:NSData = UIImagePNGRepresentation(image);
        let dataString = imgData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return dataString
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNotes" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NotesTableViewController
            controller.date = date
            controller.doctorname = doctorname
            controller.bodypart = bodypart
            controller.notes = notes
        }
        if segue.identifier == "EditNotes" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EditNotesTableViewController
            controller.date = date
            controller.doctorname = doctorname
            controller.bodypart = bodypart
            controller.notes = notes
            controller.selectedDate = photo.date
            controller.photoToEdit = photo
            controller.managedObjectContext = managedObjectContext
            controller.delegate = self
        }
    }
    
    func editNotesTableViewController(controller: EditNotesTableViewController, didFinishEditingPhoto item: Photo) {
        photo = item
        date = formatDate(photo.date)
        doctorname = photo.doctorName
        bodypart = "\(photo.category_big) - \(photo.category_small)"
        notes = photo.note
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension XrayImageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController( controller: MFMailComposeViewController!,
        didFinishWithResult result: MFMailComposeResult,
        error: NSError!) {
            dismissViewControllerAnimated(true, completion: nil)
    }
}








