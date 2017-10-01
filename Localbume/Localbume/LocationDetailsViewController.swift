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
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var dbContext: NSManagedObjectContext!
    var date = NSDate()
    
    //Edit Mode
    var descriptionText = ""
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2D(latitude: location.latitude
                    , longitude: location.longitude)
                placemark = location.placemark
            }
        }
    }
    //Photo Picker
    var image: UIImage?
    var observer: AnyObject!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        descriptionTextView.text = descriptionText
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
        dateLabel.text = format(date)
        // Books way to disable KBD
        //let aSelector = NSSelectorFromString("hideKeyboard")
        let gr = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gr.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gr)
        
        // isEditMode
        if let location = locationToEdit {
            navBarItem.title = "Edit Location"
            if location.hasPhoto {
                if let img = location.photoImage {
                    show(img)
                }
            }
        } else {
            navBarItem.title = "Tag Location"
        }
        
        // Fix for photo on change device orientation
        /*
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("UIDeviceOrientationDidChange", object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            if self.isViewLoaded() {
                self.tableView.reloadData()
            }
        }
        */
        // Background tasks
        listenForBackgroundNotification()
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
        
        var location: Location
        if let tmp = locationToEdit {
            hudView.text = "Updated"
            location = tmp
        } else {
            hudView.text = "Tagged"
            //1
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.dbContext!) as! Location
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        //image ops
        if let img = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = UIImageJPEGRepresentation(img, 0.75) {
                do {
                    try data.writeToURL(location.photoURL, atomically: true)
                } catch {
                    print("Error while writing file: \(location.photoURL)")
                }
            }
        }
        
        do {
            try dbContext.save()
            // DISPATCH - Delayed Execution Tactics (Functions.swift)
            afterDelay(0.6, closure: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            //dismissViewControllerAnimated(true, completion: nil)
        } catch let error as NSError {
            //fatalError("Kayıt sırasında hata: \(error.localizedDescription)")
            fatalCoreDateError(error)
        }
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
    
    /*
    // My Way to Disable KBD
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //super.scrollViewWillBeginDragging(scrollView)
        
        // Dismiss KBD
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width / 2, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else if indexPath.section == 1 {
            // resize for image
            if addPhotoImageView.hidden {
                return 44
            } else {
                let img = addPhotoImageView.image! as UIImage
                // isEditMode
                if let location = locationToEdit {
                    if location.hasPhoto {
                        if let _ = location.photoImage {
                            return 220
                        }
                    }
                }
                
                var nH:CGFloat = 24.0
                var scl:CGFloat = 1.0
                let w = img.size.width
                let h = img.size.height

                scl = addPhotoImageView.frame.width / w
                nH = h * scl
                
                //addPhotoImageView.frame = CGRect(x: 15.0, y: 10.0, width: 550.0, height: Double(nH))
                return round(nH) + 20
            }
        } else {
            return 44
        }
    }

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
    
    // MARK: - Destructor
    deinit {
        // print("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}

// MARK: - Photolibrary
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.showsCameraControls = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alc.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
        alc.addAction(takePhotoAction)
        
        let fromLibAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
        alc.addAction(fromLibAction)
        
        presentViewController(alc, animated: true, completion: nil)
    }
    
    func show(image: UIImage) {
        addPhotoImageView.image = image
        addPhotoImageView.hidden = false
        // addPhotoImageView.frame = CGRect(x: 15, y: 10, width: 260, height: 260)
        addPhotoImageView.image = image
        addPhotoLabel.hidden = true
    }
    
    // Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let img = image {
            show(img)
        }
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Background tasks
    func listenForBackgroundNotification() {
        let nc = NSNotificationCenter.defaultCenter()
        observer = nc.addObserverForName("UIApplicationDidEnterBackground", object: nil, queue: NSOperationQueue.mainQueue()) {
            [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}








