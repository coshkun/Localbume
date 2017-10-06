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
import QuartzCore
import AudioToolbox

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
    @IBOutlet weak var addressTextLabel: UILabel!
    @IBOutlet weak var latTextLabel: UILabel!
    @IBOutlet weak var longTextLabel: UILabel!
    @IBOutlet weak var latDegSym: UILabel!
    @IBOutlet weak var longDegSym: UILabel!
    @IBOutlet weak var latMinSym: UILabel!
    @IBOutlet weak var longMinSym: UILabel!
    @IBOutlet weak var posFinderLabel: UILabel!
    
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
    // Polish Animation
    var logoVisible = false
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: Selector("getPosition_Action:"), forControlEvents: .TouchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = self.view.bounds.midY * 6 / 8
        return button
    }()
    //Sound Operations
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // locationManager.delegate = self
        updateLabels()
        configureGetPositionButton()
        loadSoundEffect("Sound.caf")
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
                        
                        //Sound Effect Addition
                        if self.placemark == nil {
                            //print("FIRST TIME!")
                            self.playSoundEffect()
                        }//end of sound
                        
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    // Address Validation (if user spots in the midle of the ocean)
                    if let p = self.placemark {
                        if p.thoroughfare == nil || p.thoroughfare!.isEmpty {
                            self.placemark = nil
                        }
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
        
        if logoVisible {
            hideLogoView()
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
        tagButton.hidden = true
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
                tagButton.hidden = false
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for address.."
                tagButton.hidden = true
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding address!"
                tagButton.hidden = true
            } else {
                addressLabel.text = "No Address Found."
                tagButton.hidden = false
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
            tagButton.hidden = true
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
                showLogoView() //Polish Animation
            }
            
            messageLabel.text = responseMessage
        }
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
    
    // Polish Animation - Spinner Added
    func configureGetPositionButton() {
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle("Stop", forState: UIControlState.Normal)
            //Spinner starts here
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                view.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Position", forState: UIControlState.Normal)
            //Spinner Stops here
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
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
    
    //Polish Animation
    func showLogoView(){
        if !logoVisible {
            logoVisible = true
            hideAllLabels()
            logoButton.hidden = false
            view.addSubview(logoButton)
        }
    }
    func hideLogoView() {
        logoVisible = false
        //showAllLabels()
        //logoButton.hidden = true
        
        //let someX = view.bounds.size.width / 2
        //let someY = (view.bounds.size.height / 2 ) + 40
        let centerX = view.bounds.midX
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint: logoButton.center)
        logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
        
        //logoButton.removeFromSuperview()
        afterDelay(1.1, closure: {
            self.showAllLabels()
            self.logoButton.hidden = true
            self.logoButton.layer.removeAllAnimations()
            self.logoButton.removeFromSuperview()
        })
    }
    func showAllLabels(){
        messageLabel.hidden = false
        latitudeLabel.hidden = false
        longitudeLabel.hidden = false
        latDegreeLabel.hidden = false
        longDegreeLabel.hidden = false
        latMinuteLabel.hidden = false
        longMinuteLabel.hidden = false
        latSingLabel.hidden = false
        longSingLabel.hidden = false
        addressLabel.hidden = false
        addressTextLabel.hidden = false
        latTextLabel.hidden = false
        longTextLabel.hidden = false
        latDegSym.hidden = false
        longDegSym.hidden = false
        latMinSym.hidden = false
        longMinSym.hidden = false
        posFinderLabel.hidden = false
    }
    func hideAllLabels(){
        messageLabel.hidden = true
        latitudeLabel.hidden = true
        longitudeLabel.hidden = true
        latDegreeLabel.hidden = true
        longDegreeLabel.hidden = true
        latMinuteLabel.hidden = true
        longMinuteLabel.hidden = true
        latSingLabel.hidden = true
        longSingLabel.hidden = true
        addressLabel.hidden = true
        addressTextLabel.hidden = true
        latTextLabel.hidden = true
        longTextLabel.hidden = true
        latDegSym.hidden = true
        longDegSym.hidden = true
        latMinSym.hidden = true
        longMinSym.hidden = true
        posFinderLabel.hidden = true
    }
    
    //MARK: - Sound Effects
    func loadSoundEffect(name: String) {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            let fileURL = NSURL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path \(path)")
            }
        }
    }
    func unloadSoundEffect(){
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    func playSoundEffect(){
        AudioServicesPlaySystemSound(soundID)
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





