//
//  ViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/7/25.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import CoreData

class PhotoMain: UIViewController {

    var observer: AnyObject!
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var takephoto: UIButton!
    var imageToShow: UIImage?
    var imageChosen: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
       // listenForBackgroundNotification()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func TriggerCamera() {
       pickPhoto()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImage" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! PhotoShow
            controller.imageShowing = imageToShow
        }
        else if segue.identifier == "ShowGallery" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! GalleryViewController
            controller.managedObjectContext = managedObjectContext
            controller.BodyPart = "None"
        }
        else {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! GalleryViewController
            controller.managedObjectContext = managedObjectContext
            if segue.identifier == "ViewTrunk" {
                controller.BodyPart = "Trunk"
            }
            else if segue.identifier == "ViewHead" {
                controller.BodyPart = "Head"
            }
            else if segue.identifier == "ViewArm" {
                controller.BodyPart = "Arm"
            }
            else if segue.identifier == "ViewLeg" {
                controller.BodyPart = "Leg"
            }
            else {
                controller.BodyPart = "No Part"
            }
        }
    }
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(
                    UIApplicationDidEnterBackgroundNotification,
                    object: nil,
                    queue: NSOperationQueue.mainQueue())
                        { [weak self] notification in
                            if let strongSelf = self {
                                if strongSelf.presentedViewController != nil {
                                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                                }
                            }
        }
    }
    
    deinit {
        println("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}

extension PhotoMain: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        }
        else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
                
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
                
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
                
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToShow = pickedImage
            imageChosen = true
        }
//        
//        
        let photoShowViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoShowID") as! PhotoShow
        
        photoShowViewController.imageShowing = imageToShow
        
        photoShowViewController.managedObjectContext = managedObjectContext
        
        let imagePicker = self.presentedViewController as! UIImagePickerController
        
        imagePicker.pushViewController(photoShowViewController, animated: true)
        
        // dismissViewControllerAnimated(true, completion: nil)

        //performSegueWithIdentifier("ShowImage", sender: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imageChosen = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}