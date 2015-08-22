//
//  GalleryViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/10.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class GalleryViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    var BodyPart = ""
    
    var imageToShow: UIImage?
    var imageChosen: Bool?
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        if self.BodyPart != "None" && self.BodyPart != "No Part" {
            let pred = NSPredicate(format: "(category_big = %@)", self.BodyPart)
            fetchRequest.predicate = pred
        }
        
        let sortDescriptor1 = NSSortDescriptor(key: "category_small", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(  fetchRequest: fetchRequest,
                                                                    managedObjectContext: self.managedObjectContext,
                                                                    sectionNameKeyPath: "category_small",
                                                                    cacheName: nil)
        fetchedResultsController.delegate = self
        
       // println("sections count is \(fetchedResultsController.sections!.count)")
        return fetchedResultsController
        }()
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBOutlet weak var select: UIBarButtonItem!
    
    func showActionMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let EmailAction = UIAlertAction(title: "Send via Email", style: .Default, handler:  {_ in self.sendEmail()})
        alertController.addAction(EmailAction)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {_ in self.multipleDeletion()})
        alertController.addAction(DeleteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    func multipleDeletion() {
        var countRows = tableView.indexPathsForSelectedRows()?.count
        for var i = 0; i < countRows; i++ {
            println("begin")
            updateCount()
            let indexpath = tableView.indexPathsForSelectedRows()?[0] as! NSIndexPath
            let photo = fetchedResultsController.objectAtIndexPath(indexpath) as! Photo
            photo.removePhotoFile()
            managedObjectContext.deleteObject(photo)
            
            var error: NSError?
            if !managedObjectContext.save(&error) {
                fatalCoreDataError(error)
            }
            println("end")
            updateCount()
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
                controller.setSubject(NSLocalizedString("Xray Photos", comment: "Email subject"))
                controller.setToRecipients(["aaa@bbb.com"])
                
                var image: UIImage?
                var imageString = ""
                var emailbody = "These are my Xray Photos that I want to show you." + "\n" + "\n"
                var tempstring = ""
                var countImages = tableView.indexPathsForSelectedRows()?.count
                for var i = 0; i < countImages; i++ {
                    let indexpath = tableView.indexPathsForSelectedRows()?[i] as! NSIndexPath
                    let photo = fetchedResultsController.objectAtIndexPath(indexpath) as! Photo
                    
                    let filePath = photo.photoPath
                    println("File path loaded.")
                    
                    if let fileData = NSData(contentsOfFile: filePath) {
                        println("File data loaded.")
                        controller.addAttachmentData(fileData, mimeType: "image/jpeg",
                                                        fileName: "Photo-\(photo.photoID!.integerValue)")
                    }
                    
                    image = photo.photoImage
                    if let image = image {
                        imageString = returnEmailStringBase64EncodedImage(image)
                    }
                    tempstring = "<img src='data:image/png;base64,\(imageString)' width='\(image!.size.width/3)' height='\(image!.size.height/3)'>"
                    emailbody = emailbody + "\n" + tempstring
                }
                
                controller.setMessageBody("These are my Xray Photos that I want to show you.", isHTML: true)
                
                controller.mailComposeDelegate = self
                self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    func returnEmailStringBase64EncodedImage(image:UIImage) -> String {
        let imgData:NSData = UIImagePNGRepresentation(image);
        let dataString = imgData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return dataString
    }
    
    @IBAction func ActionMenu() {
        showActionMenu()
    }
    
    @IBOutlet weak var selectedActionButton: UIBarButtonItem!

    @IBOutlet weak var camera: UIBarButtonItem!
    
    @IBAction func triggerCamera() {
        pickPhoto()
    }
    
    @IBAction func selectbutton() {
        if self.navigationItem.rightBarButtonItem?.title == "Select" {
            self.navigationController?.toolbarHidden = false
            self.title = "Choose image"
            self.navigationItem.rightBarButtonItem?.title = "Cancel"
            self.navigationItem.leftBarButtonItem?.enabled = false
            
        
            self.navigationItem.leftBarButtonItem?.title = ""
            selectedActionButton.enabled = false
            camera.enabled = false
            self.tableView.allowsMultipleSelection = true
            setupForMultiSelection()
            
        }
        else {
            self.navigationController?.toolbarHidden = false
            if BodyPart != "None" && BodyPart != "No Part" {
                self.title = "\(BodyPart)"
            }
            else {
                self.title = "Gallery"
            }
            selectedActionButton.enabled = false
            camera.enabled = true
            self.navigationItem.rightBarButtonItem?.title = "Select"
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.navigationItem.leftBarButtonItem?.title = "Back"

            setupForMultiSelection()
            self.tableView.allowsMultipleSelection = false
        }
    }
    
    func setupForMultiSelection() {
        if let lists = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            for list in lists {
                tableView.deselectRowAtIndexPath(list, animated: true)
                let cell = tableView.cellForRowAtIndexPath(list) as! PhotoCell
                cell.configurecheckmark()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = false
        selectedActionButton.enabled = false
        
        if BodyPart != "None" && BodyPart != "No Part" {
            self.title = "\(BodyPart)"
        }
        else {
            self.title = "Gallery"
        }
        performFetch()
    }
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
       
        return sectionInfo.name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
       
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotoCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.configureForPhoto(photo)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.title == "Choose image" {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PhotoCell{
                cell.configurecheckmark()
                println(" \(indexPath.section)   11111  \(indexPath.row)   111111   \(cell.selected)")
            }
            if tableView.indexPathsForSelectedRows() == nil {
                selectedActionButton.enabled = false
            }
            else {
                selectedActionButton.enabled = true
            }
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("ShowXrayImage", sender: fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
       updateCount()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.title == "Choose image" {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PhotoCell {
                cell.configurecheckmark()
                println(" \(indexPath.section)   22222  \(indexPath.row)   22222   \(cell.selected)")
            }
            if tableView.indexPathsForSelectedRows() == nil {
                selectedActionButton.enabled = false
            }
            else {
                selectedActionButton.enabled = true
            }
        }
        updateCount()
    }
    
    func updateCount() {
        if let list = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            println(list.count)
        }

    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                            forRowAtIndexPath indexPath: NSIndexPath) {
                        
        if editingStyle == .Delete {
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            photo.removePhotoFile()
            managedObjectContext.deleteObject(photo)
                                    
            var error: NSError?
            if !managedObjectContext.save(&error) {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowXrayImage" {
            let controller = segue.destinationViewController as! XrayImageViewController
            let photo = sender as! Photo
            controller.photo = photo
            controller.imageShowing = photo.photoImage
            controller.date = formatDate(photo.date)
            controller.doctorname = photo.doctorName
            controller.bodypart = "\(photo.category_big) - \(photo.category_small)"
            controller.notes = photo.note
            controller.managedObjectContext = managedObjectContext
        }
    }
    
}

extension GalleryViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
                        
        switch type {
                        
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                        
            case .Delete:
                println("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade)
                        
            case .Update:
                println("*** NSFetchedResultsChangeUpdate (object)")
                if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? PhotoCell {
                    let photo = controller.objectAtIndexPath(indexPath!) as! Photo
                    cell.configureForPhoto(photo)
                }

            case .Move:
                println("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!],withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {

        switch type {
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        
            case .Update:
                println("*** NSFetchedResultsChangeUpdate (section)")
            
            case .Delete:
                println("*** NSFetchedResultsChangeDelete (section)")
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            case .Move:
                println("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}


extension GalleryViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController( controller: MFMailComposeViewController!,
                                didFinishWithResult result: MFMailComposeResult,
                                error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
        self.selectbutton()
    }
}


extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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












