//
//  Functions.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/11.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
}()

func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
}

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .NoStyle
    return formatter
    }()