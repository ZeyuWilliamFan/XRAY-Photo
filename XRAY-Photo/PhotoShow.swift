//
//  PhotoShow.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/7/25.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit

class PhotoShow: UIViewController {

    @IBOutlet weak var ImageViewShowing: UIImageView!
    var imageShowing: UIImage?
    
    @IBAction func doneCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageViewShowing.image = imageShowing

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
