//
//  BodyLocationChooseViewController.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/1.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit
import CoreData

class BodyLocationChooseViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    var image: UIImage?
    
    @IBOutlet weak var BellyButton: UIButton!
    
    @IBOutlet weak var BodyView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  BodyView.image = UIImage(named: "male.png")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            let controller = segue.destinationViewController as! AddPhotoDetailViewController
            controller.managedObjectContext = managedObjectContext
            controller.image = image
            if segue.identifier == "ToAddTrunk" {
                controller.categoryBigName = "Trunk"
            }
            else if segue.identifier == "ToAddHead" {
                controller.categoryBigName = "Head"
            }
            else if segue.identifier == "ToAddArm" {
                controller.categoryBigName = "Arm"
            }
            else if segue.identifier == "ToAddLeg" {
                controller.categoryBigName = "Leg"
            }
            else {
                controller.categoryBigName = "None"
            }

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
