//
//  AppDelegate.swift
//  Localbume
//
//  Created by coskun on 26.08.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coreDataFileName = "LocalbumeDB"
    
    
    // Application Document Directory
    lazy var appDocumentsDir: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0] as NSURL
        }()
    // MARK: - CoreData Constractors
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let dbURL = self.appDocumentsDir.URLByAppendingPathComponent("\(self.coreDataFileName).sqlite")
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        } catch let error as NSError {
            print("Sorry.. there was an error while starting db: \(error.localizedDescription)")
        }
        return coordinator
    }()
    
    // or shortly dbContex
    lazy var managedObjectContext: NSManagedObjectContext = {
    //    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the
    //    application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to
    //    fail.
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType )
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let e as NSError {
                print("Data Saving Error on Contex: \(e.localizedDescription)")
                abort()
            }
        }
    }
    
    // MARK: - AppDelegate Standart Calls
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let tabBarCon = window!.rootViewController as! UITabBarController
        if let con = tabBarCon.viewControllers {
            let currentLVC = con[0] as! CurrentLocationViewController
            currentLVC.dbContext = managedObjectContext
        }
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Notification Listeners
    func listenForFatalCoreDataNotifications() {
        //1
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("MyMOCsaveDidFailNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            //2
            let alert = UIAlertController(
                title: "Internal Error",
                message: "There was an fatal error in the app and it can not continue.\n\n"
                + "Press OK to terminate. Sorry for inconvenience.",
                preferredStyle: UIAlertControllerStyle.Alert)
            //3
            let action = UIAlertAction(title:"OK", style: .Default) { _ in
                let exeption = NSException(
                    name: "internalInconsistencyException",
                    reason: "Fatal Core Data Error",
                    userInfo: nil)
                exeption.raise()
            }
            alert.addAction(action)
            self.getViewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func getViewControllerForShowingAlert() -> UIViewController {
        let rw = self.window!.rootViewController!
        if let presented = rw.presentedViewController {
            return presented
        } else {
            return rw
        }
    }
}

