//
//  NotesViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/20.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    
    var date = ""
    var doctorname = ""
    var bodypart = ""
    var notes = ""
    
    @IBOutlet weak var notestextview: UITextView!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var doctornamelabel: UILabel!
    @IBOutlet weak var bodypartlabel: UILabel!
    
    @IBAction func donebarbutton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datelabel.text = date
        doctornamelabel.text = doctorname
        bodypartlabel.text = bodypart
        notestextview.text = notes
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 
}
