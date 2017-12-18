//
//  UserLocationController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/18/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CoreData


class UserLocationController {
    
    static let shared = UserLocationController()
    
    func createLocationWith(lat: Double, long: Double, zip: String) {
        UserLocation(latitude: lat, longitude: long, zip: zip)
        saveToPersistentStore()
    }
    
    func update(lat: Double, long: Double, zip: String) {
        guard let oldLocation = fetchUserLocation() else {return}
        oldLocation.latitude = lat
        oldLocation.longitude = long
        oldLocation.zip = zip
        
        saveToPersistentStore()
    }
    
    
    func fetchUserLocation() -> UserLocation? {
        let request: NSFetchRequest<UserLocation> = UserLocation.fetchRequest()
        guard let currentLocation = try? CoreDataStack.context.fetch(request).first else {return nil}
        return currentLocation
    }
    
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.context
        
        do {
            try moc.save()
        } catch let error {
            NSLog("There was a problem saving the users location to the persitent store: \(error) in function \(#function)")
        }
    }
    
    
}
