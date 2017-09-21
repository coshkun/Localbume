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
    
    var dbContext: NSManagedObjectContext!
    // var locations: [Location]?
    // local field for singleton pattern
    // var _frc: NSFetchedResultsController? = nil
    var fetchedResultsController: NSFetchedResultsController!
    // let appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        /*
        let fetchRequest = getFetchRequest()
        //4
        do {
            locations = try dbContext.executeFetchRequest(fetchRequest) as? [Location]
        } catch let error as NSError {
            print(error.localizedDescription)
            // fatalCoreDateError(error)
        }
        */
        fetchedResultsController.delegate = self
        performFetch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performFetch()
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            fatalCoreDateError(e)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let num = fetchedResultsController.sections!.count
        return num
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let secInfo = fetchedResultsController.sections![section]
        return secInfo.name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        let objs = sectionInfo.objects!
        return objs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: LocationCell
        if let cll = tableView.dequeueReusableCellWithIdentifier("LocationProtoCell", forIndexPath: indexPath) as? LocationCell {
            cell = cll
        } else {
            cell = LocationCell()
        }
        
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
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
            let location = fetchedResultsController.objectAtIndexPath(indexPath)
            dbContext.deleteObject(location as! NSManagedObject)
            do {
                try dbContext.save()
            } catch let e as NSError { fatalCoreDateError(e) }
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
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
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
        print("*** controllerWillChangeContent")
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChange anObject: Any, at indexPath: NSIndexPath?, forType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            print(" *** inserting")
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
        case .Delete:
                print(" *** deleting")
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
        case .Update:
            print(" *** updating")
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
                let location = controller.objectAtIndexPath(indexPath!) as! Location
                cell.configure(location)
            }
            
        case .Move:
            print(" *** moving")
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, forType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            print(" *** Inserting Section")
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
        case .Delete:
            print(" *** Deleting Section")
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
        case .Update:
            print(" *** Updating Section (not implemented)")
        case .Move:
            print(" *** Moving Section (not implemented)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        self.tableView.endUpdates()
    }
}











