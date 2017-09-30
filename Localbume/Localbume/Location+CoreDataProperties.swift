//
//  Location+CoreDataProperties.swift
//  Localbume
//
//  Created by coskun on 21.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

extension Location {
    @nonobjc class func fetchRequest() -> NSFetchRequest {
        let fr = NSFetchRequest(entityName: "Location")
        return fr
    }

    @NSManaged var category: String
    @NSManaged var date: NSDate
    @NSManaged var latitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var longitude: Double
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var photoID: NSNumber?
}
