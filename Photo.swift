//
//  Photo.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/7.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import Foundation
import CoreData
//import UIKit
import UIKit

class Photo: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var doctorName: String
    @NSManaged var note: String
    @NSManaged var category_big: String
    @NSManaged var category_small: String
    @NSManaged var photoID: NSNumber?
    
    var photoPath: String {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        let path = photoPath
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            var error: NSError?
            if !fileManager.removeItemAtPath(path, error: &error) {
                println("Error removing file: \(error!)")
            }
        }
    }

}
