//
//  MyTabBarController.swift
//  Localbume
//
//  Created by coskun on 4.10.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
