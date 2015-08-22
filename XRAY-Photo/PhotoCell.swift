//
//  PhotoCell.swift
//  XRAY-Photo
//
//  Created by Zeyu Fan on 15/8/11.
//  Copyright (c) 2015年 Zeyu Fan. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {

    var cellIsSelected = false
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
   
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configureForPhoto(photo: Photo) {
        if photo.note.isEmpty {
            noteLabel.text = "(No Description)"
        } else {
            noteLabel.text = photo.note
        }
        
        dateLabel.text = formatDate(photo.date)
        photoImageView.image = imageForPhoto(photo)
    }
    
    func configurecheckmark() {
        //cellIsSelected = !cellIsSelected
        if selected == false {
            checkmarkImageView.image = nil
        }
        else {
            checkmarkImageView.image = UIImage(named: "checkmarkwhite")
        }
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    func imageForPhoto(photo: Photo) -> UIImage {
 
        if let image = photo.photoImage {
            return image
        }

        return UIImage()
    }
    
}
