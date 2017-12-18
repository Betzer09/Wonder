//
//  UserLocation+Convience.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/18/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CoreData

extension UserLocation {
    
    @discardableResult convenience init(latitude: Double, longitude: Double, zip: String, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.zip = zip
    }
    
}
