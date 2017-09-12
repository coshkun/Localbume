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