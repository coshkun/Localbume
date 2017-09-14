//
//  FirstViewController.swift
//  Localbume
//
//  Created by coskun on 26.08.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Foundation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latDegreeLabel: UILabel!
    @IBOutlet weak var longDegreeLabel: UILabel!
    @IBOutlet weak var latMinuteLabel: UILabel!
    @IBOutlet weak var longMinuteLabel: UILabel!
    @IBOutlet weak var latSingLabel: UILabel!
    @IBOutlet weak var longSingLabel: UILabel!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    // Reverse Geo variables
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: NSTimer?
    // Core Data
    var dbContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // locationManager.delegate = self
        updateLabels()
        configureGetPositionButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //print("didFailWithError: \(error.description)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetPositionButton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        //print("didUpdateLocations: \(newLocation)")
        
        //1
        if newLocation?.timestamp.timeIntervalSinceNow < -5 { return }
        //2
        if newLocation?.horizontalAccuracy < 0 { return }
        
        //iPod Correction
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation!.distanceFromLocation(location)
        }
        
        
        //3
        if location == nil ||
            location!.horizontalAccuracy > newLocation?.horizontalAccuracy {
            //4
            location = newLocation
            updateLabels()
            lastLocationError = nil
                
            if newLocation?.horizontalAccuracy <= locationManager.desiredAccuracy {
                //print("*** We're done! ***")
                stopLocationManager()
                configureGetPositionButton()
                
                //iPod Correction
                if distance > 0 { //that means we are moving
                    performingReverseGeocoding = false
                }
            }
            
            // Start of re-geocoding
            if !performingReverseGeocoding {
                //print("*** Going to geocode ***")
                performingReverseGeocoding = true
                // CLOSURE
                geocoder.reverseGeocodeLocation(newLocation!, completionHandler: {
                    placemarks, error in
                    //print("** Found placemarks \(placemarks), error: \(error)")
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        //iPod Correction
        } else if distance < 1 { // that means small deviations under 1m.
            let timeInterval = newLocation?.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                //print("*** Force Done!")
                stopLocationManager()
                updateLabels()
                configureGetPositionButton()
            }
        }
        

    }

    @IBAction func getPosition_Action(sender: UIButton) {
        let authState = CLLocationManager.authorizationStatus()
        
        if authState == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        else if authState == CLAuthorizationStatus.Denied || authState == CLAuthorizationStatus.Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
            configureGetPositionButton()
            messageLabel.text = "Stopped."
        } else {
            location = nil
            lastLocationError = nil
            
            placemark = nil
            lastGeocodingError = nil
            
            startLocationManager()
            updateLabels()
            configureGetPositionButton()
        }
    }
    
    @IBAction func tagPosition_Action(sender: AnyObject) {
        
        //after we done here disable tagButton
        tagButton.enabled = false
    }
    
    // MARK: - Helpers
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        //present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",  location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f",  location.coordinate.longitude)
            
            let latDeg = abs(Int(location.coordinate.latitude))
            let lonDeg = abs(Int(location.coordinate.longitude))
            let latMin = abs(Double(location.coordinate.latitude)) - Double(latDeg)
            let lonMin = abs(Double(location.coordinate.longitude)) - Double(lonDeg)
            
            latDegreeLabel.text = String(latDeg)
            longDegreeLabel.text = String(format: "%03d", lonDeg)
            latMinuteLabel.text = String(format: "%07.4f", latMin * 60)
            longMinuteLabel.text = String(format: "%07.4f", lonMin * 60)
            latSingLabel.text = getSingOfLat(location.coordinate.latitude)
            longSingLabel.text = getSingOfLong(location.coordinate.longitude)
            
            // Hata yoksa göstergeyi kullan
            if lastLocationError == nil {
                let frm = NSDateFormatter()
                frm.dateFormat = "yyyy-MM-dd - HH:mm:ss"
                messageLabel.text = "Updated on: \(frm.stringFromDate(location.timestamp))"
            }
            // Adress label text
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
                tagButton.enabled = true
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for address.."
                tagButton.enabled = false
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding address!"
                tagButton.enabled = false
            } else {
                addressLabel.text = "No Address Found."
                tagButton.enabled = false
            }
            // ** End of reverse geocoding
        } else {
            latitudeLabel.text = "?? - ????"
            longitudeLabel.text = "?? - ????"
            
            latDegreeLabel.text = "00"
            longDegreeLabel.text = "00"
            latMinuteLabel.text = "00,0000"
            longMinuteLabel.text = "00,0000"
            addressLabel.text = "- ??? -"
            tagButton.enabled = false
            latSingLabel.text = "--"
            longSingLabel.text = "--"
            
            messageLabel.text = "Tap to 'Get My Position' first."
            // Error Handlers start here
            var responseMessage: String
            if let error = lastLocationError as NSError! {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue{
                    responseMessage = "No location service permission. Go to your settings to fix it."
                } else {
                    responseMessage = "Error getting location."
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                responseMessage = "Location services disabled."
            } else if updatingLocation {
                responseMessage = "Searching..."
            } else {
                responseMessage = "Tap 'Get My Position' to start."
            }
            
            messageLabel.text = responseMessage
        }
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
            line2 += s + " "
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
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            //prepare watchdog - #selector(didTimeOut) in Swift3
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "didTimeOut", userInfo: nil, repeats: false)
            
        }
    }
    
    func stopLocationManager(){
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            //kill the dog if exist
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func configureGetPositionButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: UIControlState.Normal)
        } else {
            getButton.setTitle("Get My Position", forState: UIControlState.Normal)
        }
    }
    
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
    
    @objc func didTimeOut(){
        // this fires itself after 60sn from start of location manager
        //print("*** Time Out!")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "LocalbumeErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetPositionButton()
        }
    }
    
    //MARK: - App Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocationSegue" {
            let navcon = segue.destinationViewController as! UINavigationController
            let con = navcon.topViewController as! LocationDetailsViewController
            
            con.coordinate = location!.coordinate
            con.placemark = placemark
            con.dbContext = dbContext
        }
    }
}

