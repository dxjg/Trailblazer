//
//  Trail.swift
//  Trailblazer
//
//  Created by David Gong on 1/31/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit
import os.log

class Trail: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var date: Date?
    var distance: Double?
    var trailDescription: String
    var descriptionColor: UIColor
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("trails")
    
    // MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let date = "date"
        static let trailDescription = "description"
        static let descriptionColor = "descriptionColor"
    }
    
    init?(name: String, photo: UIImage?, date: Date, trailDescription: String, descriptionColor: UIColor) {
        // The name cannot be empty.
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.date = date
        self.trailDescription = trailDescription
        self.descriptionColor = descriptionColor
    }
 
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(trailDescription, forKey: PropertyKey.trailDescription)
        aCoder.encode(descriptionColor, forKey: PropertyKey.descriptionColor)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Trail object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // The date is required. If we cannot decode a date object, the initializer should fail.
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date else {
            os_log("Unable to decode the date for a Trail object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let trailDescription = aDecoder.decodeObject(forKey: PropertyKey.trailDescription) as? String ?? TrailViewController.descriptionPlaceholder
        
        let descriptionColor = aDecoder.decodeObject(forKey: PropertyKey.descriptionColor) as? UIColor ?? UIColor.lightGray
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, date: date, trailDescription: trailDescription, descriptionColor: descriptionColor)
    }
    
}
