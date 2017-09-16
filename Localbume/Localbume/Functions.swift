//
//  Functions.swift
//  Localbume
//
//  Created by coskun on 11.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import Dispatch
import CoreLocation

func afterDelay(seconds: Double, closure: () -> () ) {
    let exeTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(seconds * Double(NSEC_PER_SEC)))
    let mainQueue = dispatch_get_main_queue()
    
    dispatch_after(exeTime, mainQueue, closure)
}

let appDocsDir: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[0] as NSURL
}()

//let MyMOCsaveDidFailNotification = NSNotification.Name(rawValue: "MyMOCsaveDidFailNotification")

func fatalCoreDateError(error: NSError) {
    let nc = NSNotificationCenter.defaultCenter()
    nc.postNotificationName("MyMOCsaveDidFailNotification",
                            object: nil,
                            userInfo: ["message":"Sorry.. Deadly saving error. Pls, inform developer how did you do that.",
                                        "date":NSDate()])

    print("*** fatal Error: \(error)")
}

// Addres Parsers
func string(from placemark: CLPlacemark) -> String {
    // 1
    var line1 = ""
    //2
    if let s = placemark.subThoroughfare {
        line1 += s + " "
    }
    //3
    if let s = placemark.thoroughfare {
        line1 += s
    }
    //4
    var line2 = ""
    if let s = placemark.locality {
        line2 += s + " \n"
    }
    if let s = placemark.administrativeArea {
        line2 += s + " "
    }
    if let s = placemark.postalCode {
        line2 += s + " - "
    }
    if let s = placemark.country {
        line2 += s
    }
    
    return line1 + "\n" + line2
}

func stringToSingleLine(from placemark: CLPlacemark) -> String {
    // 1
    var line1 = ""
    //2
    if let s = placemark.subThoroughfare {
        line1 += s + " "
    }
    //3
    if let s = placemark.thoroughfare {
        line1 += s
    }
    //4
    var line2 = ""
    if let s = placemark.locality {
        line2 += s + ", "
    }
    if let s = placemark.administrativeArea {
        line2 += s + " "
    }
    if let s = placemark.postalCode {
        line2 += s + " - "
    }
    if let s = placemark.country {
        line2 += s
    }
    
    return line1 + ", " + line2
}

// GEO Parsers
func getSingOfLat(latitude: CLLocationDegrees) -> String {
    var sng = "--"
    if Double(latitude) < -0.00000833 { sng = "S" }
    else if Double(latitude) >  0.00000833 { sng = "N" }
    else { sng = "--" }
    return sng
}

func getSingOfLong(longitude: CLLocationDegrees) -> String {
    var sng = "--"
    if Double(longitude) < -0.00000833 { sng = "W" }
    else if Double(longitude) >  0.00000833 { sng = "E" }
    else { sng = "--" }
    return sng
}

func stringFromPosition(lat: Double, long: Double) -> String {
    var line1 = ""
    var line2 = ""
    
    let degOfLat = abs(Int(lat))
    let degOfLong = abs(Int(long))
    let minOfLat = (abs(Double(lat)) - Double(degOfLat)) * 60
    let minOfLong = (abs(Double(long)) - Double(degOfLong)) * 60
    
    line1 = String(degOfLat) + "° " + String(format: "%07.4f", minOfLat) + " ' " + getSingOfLat(lat)
    line2 = String(format: "%03d", degOfLong) + "° " + String(format: "%07.4f", minOfLong) + " ' " + getSingOfLong(long)
    
    return line1 + "\t" + line2
}



