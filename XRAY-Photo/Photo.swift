//
//  Photo.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/7.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var doctorName: String
    @NSManaged var note: String
    @NSManaged var category_big: String
    @NSManaged var category_small: String

}
