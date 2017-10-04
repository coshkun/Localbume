//
//  LocationsViewController.swift
//  Localbume
//
//  Created by coskun on 15.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    // @IBOutlet weak var descriptionLabel: UILabel!
    // @IBOutlet weak var addressLabel: UILabel!
    
    
    var dbContext: NSManagedObjectContext! /* {
        didSet {
            let nc = NSNotificationCenter.defaultCenter()
            nc.addObserverForName("NSManagedObjectContextObjectsDidChange", object: dbContext, queue: NSOperationQueue.mainQueue()) { notification in
                
                if self.isViewLoaded() {
                    self.performFetch()
                    self.tableView.reloadData()
                }
                // End of Scope
            }
        }
    } */
    
    var locations: [Location]? = nil
    var kategoriler: [String]?
    var data = [String:[Location]]()
    // local field for singleton pattern
    // var fetchedResultsController: NSFetchedResultsController!
    // let appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()

        // fetchedResultsController.delegate = self
        // performFetch()
        // COLORIZING:
        tableView.backgroundColor = UIColor(white: 11/255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(white: 0.0, alpha: 1.0)
        tableView.indicatorStyle = .White
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func getFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        let sortDesc = NSSortDescriptor(key: "date", ascending: false)
        let sortDesc2 = NSSortDescriptor(key: "category", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc2, sortDesc]
        //2
        // let entity = Location().entity
        // fetchRequest.entity = entity
        // fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
    
    // FetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        if self._frc != nil {
            return self._frc!
        }
        
        let fetchRequest = self.getFetchRequest()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dbContext, sectionNameKeyPath: "category", cacheName: nil) // cacheName: "Locations"
        
        fetchedResultsController.delegate = self
        self._frc = fetchedResultsController
        return fetchedResultsController
    }()
    var _frc: NSFetchedResultsController? = nil
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            fatalCoreDateError(e)
        }
    }
    
    func refreshData() {
        let fetchRequest = getFetchRequest()
        if locations != nil {
            locations = nil
        }
        //4
        do {
        locations = try dbContext.executeFetchRequest(fetchRequest) as? [Location]
        } catch let error as NSError {
        print("Error on fetching: \(error.localizedDescription)")
        // fatalCoreDateError(error)
        }
        
        kategoriler = [String]()
        for location in locations! {
            if !(kategoriler!.contains(location.category)) {
                kategoriler?.append(location.category)
            }
        }
        
        for kat in kategoriler! {
            var loc = [Location]()
            for itm in locations! {
                if itm.category == kat {
                    loc.append(itm)
                }
            }
            data[kat] = loc
        }
        
        //print(data.count)
        //print("Kategoriler: \(kategoriler!.count)")
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // if let sec = fetchedResultsController.sections {
        //    return sec.count
        // }
        if let kats = kategoriler {
            return kats.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*
        if let sections = fetchedResultsController.sections {
            let currentSec = sections[section]
            return currentSec.name
        } */
        if let kats = kategoriler {
            return kats[section] as String
        }
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        /*
        if let sections = fetchedResultsController.sections {
            let currentSec = sections[section]
            return currentSec.numberOfObjects
        }
        */
        if let kats = kategoriler {
            var cnt = 0
            for itm in locations! {
                if itm.category == kats[section] { cnt += 1 }
            }
            //print("Kısım: \(section) Adet: \(cnt)")
            return cnt
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: LocationCell
        if let cll = tableView.dequeueReusableCellWithIdentifier("LocationProtoCell", forIndexPath: indexPath) as? LocationCell {
            cell = cll
        } else {
            cell = LocationCell()
        }
        //let cell = tableView.dequeueReusableCellWithIdentifier("LocationProtoCell", forIndexPath: indexPath) as! LocationCell
        //let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        let locs = data[kategoriler![indexPath.section]]
        let location = locs![indexPath.row]
            cell.configure(location)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            // let location = locations![indexPath.row]
            let locs = data[kategoriler![indexPath.section]]
            let location = locs![indexPath.row]
            
            location.removePhotoFile()
            dbContext.deleteObject(location)
            do {
                try dbContext.save()
            } catch let e as NSError { fatalCoreDateError(e) }
            
            refreshData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditLocationSegue" {
            let navCon = segue.destinationViewController as! UINavigationController
            let viewCon = navCon.viewControllers[0] as! LocationDetailsViewController
            
            viewCon.dbContext = dbContext
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                //let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                //let location = locations![indexPath.row]
                let locs = data[kategoriler![indexPath.section]]
                let location = locs![indexPath.row]
                viewCon.locationToEdit = location
            }
        }
    }
    
    // MARK: - Termination
    deinit {
        fetchedResultsController.delegate = nil
    }
}



extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // print("*** controllerWillChangeContent")
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChange anObject: Any, at indexPath: NSIndexPath?, forType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            //print(" *** inserting")
            if let InsertPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([InsertPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        case NSFetchedResultsChangeType.Delete:
            //print(" *** deleting")
            if let deletePath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([deletePath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        case NSFetchedResultsChangeType.Update:
            //print(" *** updating")
            if let updatePath = indexPath {
                let cell = self.tableView.cellForRowAtIndexPath(updatePath) as! LocationCell
                let location = self.fetchedResultsController.objectAtIndexPath(updatePath) as! Location
                cell.configure(location)
            }
            
        case NSFetchedResultsChangeType.Move:
            //print(" *** moving")
            if let deletePath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([deletePath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            if let InsertPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([InsertPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, forType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            // print(" *** Inserting Section")
            let secIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.insertSections(secIndexSet, withRowAnimation: .Automatic)
        case .Delete:
            // print(" *** Deleting Section")
            let secIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.deleteSections(secIndexSet, withRowAnimation: .Automatic)
            /*
            case .Update:
            print(" *** Updating Section (not implemented)")
            case .Move:
            print(" *** Moving Section (not implemented)")
            }
            */
        default:
            ""
        }
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // print("*** controllerDidChangeContent")
        self.tableView.endUpdates()
    }
}






