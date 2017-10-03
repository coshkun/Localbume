//
//  String+AddText.swift
//  Localbume
//
//  Created by coskun on 3.10.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text:String?, separatedBy separator:String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}