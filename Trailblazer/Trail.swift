//
//  Trail.swift
//  Trailblazer
//
//  Created by David Gong on 1/31/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit

class Trail {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var date: Date
    var description: String
    
    init?(name: String, photo: UIImage?, date: Date, description: String) {
        // The name cannot be empty.
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.date = date
        self.description = description
    }
    
}
