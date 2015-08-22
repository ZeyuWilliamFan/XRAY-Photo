//
//  EditNotesTableViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/22.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import CoreData

protocol EditNotesTableViewControllerDelegate: class {
    func editNotesTableViewController(controller: EditNotesTableViewController, didFinishEditingPhoto item: Photo)
}

class EditNotesTableViewController: UITableViewController {

    weak var delegate: EditNotesTableViewControllerDelegate?
        
    var managedObjectContext: NSManagedObjectContext!
    
    var selectedDate = NSDate()
    var datePickerVisible = false
    
    var photoToEdit: Photo!
    
    var date = ""
    var doctorname = ""
    var bodypart = ""
    var notes = ""
    
    var NotesText = ""
    var DoctorNameText = ""
    
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var DoctorNameTextView: UITextView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var NotesTextView: UITextView!
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done() {
        
        
        photoToEdit.note = NotesText
        photoToEdit.doctorName = DoctorNameText
        photoToEdit.date = selectedDate
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        delegate?.editNotesTableViewController(self, didFinishEditingPhoto: photoToEdit)
        
        //dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CategoryLabel.text = bodypart
        DoctorNameTextView.text = doctorname
        NotesTextView.text = notes
        DateLabel.text = date
        
        NotesText = notes
        DoctorNameText = doctorname
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        DoctorNameTextView.becomeFirstResponder()
        
    }
    

    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && (indexPath!.section == 0 || indexPath!.section == 3 ){
            return
        }
        
        DoctorNameTextView.resignFirstResponder()
        NotesTextView.resignFirstResponder()
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
        DateLabel.text = formatDate(selectedDate)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NotesTextView.frame.size.width = view.frame.size.width - 30
        DoctorNameTextView.frame.size.width = view.frame.size.width - 30
            
    }
    

}



extension EditNotesTableViewController: UITextViewDelegate {
        
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        if textView.tag == 100 {
            DoctorNameText = (textView.text as NSString).stringByReplacingCharactersInRange( range, withString: text)
        }
        
        if textView.tag == 101 {
            NotesText = (textView.text as NSString).stringByReplacingCharactersInRange( range, withString: text)
        }
        return true
    }
        
    func textViewDidEndEditing(textView: UITextView) {
        if textView.tag == 100 {
            DoctorNameText = textView.text
        }
        
        if textView.tag == 101 {
            NotesText = textView.text
        }
    }

        
    func textViewDidBeginEditing(textView: UITextView) {

        hideDatePicker()
    }
}








