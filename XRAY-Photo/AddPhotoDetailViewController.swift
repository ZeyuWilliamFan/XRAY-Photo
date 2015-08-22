//
//  AddPhotoDetailViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/1.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import CoreData

class AddPhotoDetailViewController: UITableViewController {
    
    var image: UIImage?
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = NSDate()
    
    @IBOutlet weak var doctorNameTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var NoteTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var selectedDate = NSDate()
    var datePickerVisible = false
    
    var categoryBigName = ""
    var categoryName = "No Category"
    var NoteText = ""
    var doctorNameText = ""
    
    @IBAction func done() {
        if let a = managedObjectContext {
        }
        var xray: Photo
        xray = NSEntityDescription.insertNewObjectForEntityForName( "Photo",
                                                                    inManagedObjectContext: managedObjectContext) as! Photo
        xray.note  = NoteText
        xray.category_small = categoryName
        xray.date = selectedDate
        xray.doctorName = doctorNameText
        xray.category_big = categoryBigName
        xray.photoID = nil
        
        if let image = image {
            xray.photoID = Photo.nextPhotoID()
            let data = UIImageJPEGRepresentation(image, 0.5)
            var error: NSError?
            
            if !data.writeToFile(xray.photoPath, options: .DataWritingAtomic, error: &error) {
                println("Error writing file: \(error)")
            }
        }
        
        var error: NSError?
        
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        println("Note '\(NoteText)'")
        println("doctor name '\(doctorNameText)'")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if categoryBigName != "None" {
            self.title = "Add Xray for \(categoryBigName)"
        }
        else {
            self.title = "Add Xray"
        }
        
        NoteTextView.text = NoteText
        doctorNameTextView.text = doctorNameText
        categoryLabel.text = categoryName
        
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        doctorNameTextView.becomeFirstResponder()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && (indexPath!.section == 0 || indexPath!.section == 3 ){
            return
        }
        
        doctorNameTextView.resignFirstResponder()
        NoteTextView.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NoteTextView.frame.size.width = view.frame.size.width - 30
        doctorNameTextView.frame.size.width = view.frame.size.width - 30
        
    }
    
    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        
        if let pickerCell = tableView.cellForRowAtIndexPath( indexPathDatePicker) {
            let datePicker = pickerCell.viewWithTag(102) as! UIDatePicker
            datePicker.setDate(selectedDate, animated: false)
        }
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    func updateDueDateLabel() {
        dateLabel.text = formatDate(selectedDate)
    }
    
    func dateChanged(datePicker: UIDatePicker) {
        selectedDate = datePicker.date
        updateDueDateLabel()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 1 {
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") as? UITableViewCell
        
            if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "DatePickerCell")
                    cell.selectionStyle = .None
                    
                    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320, height: 216))
                    datePicker.datePickerMode = UIDatePickerMode.Date
                    datePicker.tag = 102
                    cell.contentView.addSubview(datePicker)
                    
                    datePicker.addTarget(self, action: Selector("dateChanged:"), forControlEvents: .ValueChanged)
            }
            return cell
        
        }
        else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
//    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        if indexPath.section == 1 && indexPath.row == 0 {
//            return indexPath
//        }
//        else {
//            return nil
//        }
//    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
            hideDatePicker()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // textField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 0 {
            if !datePickerVisible {
                    showDatePicker()
            }
            else {
                    hideDatePicker()
            }
        }
    }
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 1 && indexPath.row == 1 {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView,indentationLevelForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return 217
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 2
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    
}

extension AddPhotoDetailViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.tag == 100 {
            doctorNameText = (textView.text as NSString).stringByReplacingCharactersInRange( range, withString: text)
        }
        
        if textView.tag == 101 {
            NoteText = (textView.text as NSString).stringByReplacingCharactersInRange( range, withString: text)
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
            
        if textView.tag == 100 {
            doctorNameText = textView.text
        }
            
        if textView.tag == 101 {
            NoteText = textView.text
        }
    }
    
                
    func textViewDidBeginEditing(textView: UITextView) {
        hideDatePicker()
    }
}




















