//
//  Location.swift
//  Localbume
//
//  Created by coskun on 12.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {
    // Insert code here to add functionality to your managed object subclass
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "(No Descripion)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? {
        return category
    }
}