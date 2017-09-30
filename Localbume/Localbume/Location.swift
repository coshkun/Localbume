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
    
    //photography
    var hasPhoto: Bool {
        return (photoID != nil) ? true : false
    }
    
    var photoURL: NSURL {
        assert(photoID != nil, "No Photo ID set")
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return appDocsDir.URLByAppendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path!)
    }
    
    class func nextPhotoID() -> Int {
        let userDef = NSUserDefaults.standardUserDefaults()
        let currentID = userDef.integerForKey("PhotoID")
        userDef.setInteger(currentID + 1, forKey: "PhotoID")
        return currentID
    }
    
    func removePhotoFile(){
        if hasPhoto {
            do{
                try NSFileManager.defaultManager().removeItemAtURL(photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
}

/* 
class func nextPhotoID() -> Int {
let userDef = NSUserDefaults.standardUserDefaults()
let currentID = userDef.valueForKey("PhotoID") as! Int
userDef.setObject((currentID + 1) as Int, forKey: "PhotoID")
return currentID
}
*/




