//
//  LocationDetailsViewController.swift
//  Localbume
//
//  Created by coskun on 6.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var dbContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        let degOfLat = abs(Int(coordinate.latitude))
        let degOfLong = abs(Int(coordinate.longitude))
        let minOfLat = (abs(Double(coordinate.latitude)) - Double(degOfLat)) * 60
        let minOfLong = (abs(Double(coordinate.longitude)) - Double(degOfLong)) * 60
        
        latitudeLabel.text = String(degOfLat) + "° " + String(format: "%07.4f", minOfLat) + " ' " + getSingOfLat(coordinate.latitude)
        longitudeLabel.text = String(format: "%03d", degOfLong) + "° " + String(format: "%07.4f", minOfLong) + " ' " + getSingOfLong(coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(NSDate())
        // Books way to disable KBD
        //let aSelector = NSSelectorFromString("hideKeyboard")
        let gr = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gr.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gr)
    }
    
    @objc func hideKeyboard(gestureRecognizer: UITapGestureRecognizer){
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancel_Action(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save_Action(sender: UIBarButtonItem) {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"
        
        // DISPATCH - Delayed Execution Tactics (Functions.swift)
        afterDelay(0.6, closure: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        //dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Helpers
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
    
    func format(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    */
    
    /*
    // My Way to Disable KBD
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //super.scrollViewWillBeginDragging(scrollView)
        
        // Dismiss KBD
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    */
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width / 2, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CategoryPickerSegue" {
            let controler = segue.destinationViewController as! CategoryPickerViewController
            controler.selectedCategoryName = categoryName
        }
    }
    
    // Capture the UNWIND SEGUE
    @IBAction func categoryPickerDidPickedCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}




