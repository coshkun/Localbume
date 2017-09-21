//
//  MapViewController.swift
//  Localbume
//
//  Created by coskun on 19.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dbContext: NSManagedObjectContext!
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLocations()
        if !locations.isEmpty {
            showLocations_Action(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showUser_Action(sender: UIBarButtonItem) {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    @IBAction func showLocations_Action(sender: UIBarButtonItem?) {
        let theRegion = regionFor(locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    // MARK: - MapKit Helpers
    func updateLocations(){
        mapView.removeAnnotations(locations)
        
        let fr = NSFetchRequest(entityName: "Location")
        locations = try! dbContext.executeFetchRequest(fr) as! [Location]
        mapView.addAnnotations(locations)
    }
    
    func regionFor(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(
                        mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(
                        annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90,
                longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90,
                            longitude: -180)
        
        for annotation in annotations {
            topLeftCoord.latitude = max(topLeftCoord.latitude,
                annotation.coordinate.latitude)
            topLeftCoord.longitude = min(topLeftCoord.longitude,
                annotation.coordinate.longitude)
            bottomRightCoord.latitude = min(bottomRightCoord.latitude,
                annotation.coordinate.latitude)
            bottomRightCoord.longitude = max(bottomRightCoord.longitude,
                annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
                    latitude: topLeftCoord.latitude -
                        (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                    longitude: topLeftCoord.longitude -
                        (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
        let extraSpace = 1.1
        let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeftCoord.latitude -
                bottomRightCoord.latitude) * extraSpace,
            longitudeDelta: abs(topLeftCoord.longitude -
                bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    func showLocationDetails(sender: UIButton){
        print("Selector works with Tag: \(sender.tag)")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: - MapKit Delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //1
        guard annotation is Location else {
            return nil
        }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //3
            pinView.enabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
        
            //4
            let rightButton = UIButton(type: .DetailDisclosure)
            rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        
        if let av = annotationView {
            av.annotation = annotation
            //5
            let button = av.rightCalloutAccessoryView as! UIButton
            if let index = locations.indexOf(annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }
    
    
}









