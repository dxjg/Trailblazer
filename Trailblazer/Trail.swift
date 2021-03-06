//
//  Trail.swift
//  Trailblazer
//
//  Created by David Gong on 1/31/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit
import os.log
import HealthKit

class Trail: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var date: Date?
    var distance: Double?
    var trailDescription: String
    var descriptionColor: UIColor
    var healthKitSample: HKQuantitySample?
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("trails")
    
    // MARK: Types
    
    // A struct for containing the keys that access the archive.
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let date = "date"
        static let distance = "distance"
        static let trailDescription = "description"
        static let descriptionColor = "descriptionColor"
        static let healthKitSample = "healthKitSample"
    }
    
    init?(name: String, photo: UIImage?, date: Date, distance: Double?, trailDescription: String, descriptionColor: UIColor, healthKitSample: HKQuantitySample? = nil) {
        // The name cannot be empty.
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.date = date
        self.distance = distance
        self.trailDescription = trailDescription
        self.descriptionColor = descriptionColor
        self.healthKitSample = healthKitSample
    }
 
    // MARK: NSCoding

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(distance, forKey: PropertyKey.distance)
        aCoder.encode(trailDescription, forKey: PropertyKey.trailDescription)
        aCoder.encode(descriptionColor, forKey: PropertyKey.descriptionColor)
        aCoder.encode(healthKitSample, forKey: PropertyKey.healthKitSample)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Trail object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Trail, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // The date is required. If we cannot decode a date object, the initializer should fail.
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date else {
            os_log("Unable to decode the date for a Trail object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let distance = aDecoder.decodeObject(forKey: PropertyKey.distance) as? Double
        
        let trailDescription = aDecoder.decodeObject(forKey: PropertyKey.trailDescription) as? String ?? TrailViewController.descriptionPlaceholder
        
        let descriptionColor = aDecoder.decodeObject(forKey: PropertyKey.descriptionColor) as? UIColor ?? UIColor.lightGray
        
        let healthKitSample = aDecoder.decodeObject(forKey: PropertyKey.healthKitSample) as? HKQuantitySample
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, date: date, distance: distance, trailDescription: trailDescription, descriptionColor: descriptionColor, healthKitSample: healthKitSample)
    }
    
}
