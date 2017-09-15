//
//  Functions.swift
//  Localbume
//
//  Created by coskun on 11.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import Dispatch

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