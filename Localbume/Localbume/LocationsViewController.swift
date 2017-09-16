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
    var locations: [Location]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let fetchRequest = getFetchRequest()
        //4
        do {
            locations = try dbContext.executeFetchRequest(fetchRequest) as? [Location]
        } catch let error as NSError {
            print(error.localizedDescription)
            // fatalCoreDateError(error)
        }
    }
    
    func getFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        // Set the batch size to a suitable number.
        // fetchRequest.fetchBatchSize = 20
        let sortDesc = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        //2
        // let entity = Location().entity
        // fetchRequest.entity = entity
        return fetchRequest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (locations?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationProtoCell", forIndexPath: indexPath) as! LocationCell
        
        if let location = locations?[indexPath.row] {
            // Configure the cell...
            /*
            let descLabel = cell.viewWithTag(1001) as! UILabel
            let adrsLabel = cell.viewWithTag(1002) as! UILabel
            // Assinging
            descLabel.text = location.locationDescription
            if let pmark = location.placemark {
                adrsLabel.text = stringToSingleLine(from: pmark)
            } else {
                adrsLabel.text = ""
            }
            */
            cell.configure(location)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
