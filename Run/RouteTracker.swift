//
//  RouteTracker.swift
//  Run
//
//  Created by Steven Li on 9/23/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import CoreData
import CoreLocation
import HealthKit

let DetailSegueName = "RunDetails"

class RouteTracker: UIViewController, CLLocationManagerDelegate {
    var didFindMyLocation = false
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()



    @IBOutlet weak var MapTracker: GMSMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var staticLabelOne: UILabel!
    @IBOutlet weak var staticLabelTwo: UILabel!
    @IBOutlet weak var staticLabelThree: UILabel!
    @IBOutlet weak var staticLabelFour: UILabel!
    
    @IBAction func StartTrack(sender: AnyObject) {
        startButton.hidden = true
        promptLabel.hidden = true
        
        timeLabel.hidden = false
        distanceLabel.hidden = false
        paceLabel.hidden = false
        stopButton.hidden = false
        staticLabelOne.hidden = false
        staticLabelTwo.hidden = false
        staticLabelThree.hidden = false
        staticLabelFour.hidden = false

        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
        startLocationUpdates()
        
    }
//    @IBAction func stopPressed(sender: AnyObject) {
//        let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
//        actionSheet.actionSheetStyle = .Default
//        actionSheet.showInView(view)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? RouteInfo {
        }
    }

    let locationManager = CLLocationManager()
    var seconds = 0.0
    var distance = 0.0
    lazy var timer:NSTimer? = NSTimer()
    var locations = [CLLocation]()
    
    func saveRun(name: String) {

        var locationarray = [CLLocationCoordinate2D]()
        for location in locations{
            locationarray.append(location.coordinate)
        }
        var encodedPath:String = encodeCoordinates(locationarray)
        var path:GMSPath = GMSPath(fromEncodedPath: encodedPath)
        var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
        var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
        var cameraPosition = MapTracker.cameraForBounds(camera, insets: insets)
        MapTracker.camera = cameraPosition
        
        UIGraphicsBeginImageContext(MapTracker.frame.size)
        MapTracker.layer .renderInContext(UIGraphicsGetCurrentContext()!)
        var screenshotOfMap:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let savedRun = NSEntityDescription.entityForName("RunInfo",
            inManagedObjectContext: managedObjectContext)
        let runInfo = RunInfo(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
        let imageData = UIImageJPEGRepresentation(screenshotOfMap, 1)
        runInfo.image = imageData!
        runInfo.distance = distance
        runInfo.duration = seconds
        runInfo.timestamp = NSDate()
        runInfo.name = name
        runInfo.generated = false
        // 2
        
        for location in locations {
                let savedRun = NSEntityDescription.entityForName("Location",
                inManagedObjectContext: managedObjectContext)
            let savedlocation = Location(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
            savedlocation.timestamp = location.timestamp
            savedlocation.latitude = location.coordinate.latitude
            savedlocation.longitude = location.coordinate.longitude
            runInfo.mutableOrderedSetValueForKey("locations").addObject(savedlocation)
         
        }
    
        // 3
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")

        do {
            try managedObjectContext.save()
        } catch var error1 as NSError {
            error = error1
        }
        stopUpdatingLocation()
        
        RunInfoData = (try! managedObjectContext.executeFetchRequest(request)) as! [RunInfo]
        mainInstance.routeNumber = RunInfoData.count
    }
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        promptLabel.hidden = false
        startButton.hidden = false

        timeLabel.hidden = true
        distanceLabel.hidden = true
        paceLabel.hidden = true
        stopButton.hidden = true
        staticLabelOne.hidden  = true
        staticLabelTwo.hidden  = true
        staticLabelThree.hidden  = true
        staticLabelFour.hidden  = true
        timer!.invalidate()
        timer = nil
        locations.removeAll(keepCapacity: false)
        timeLabel.text = "0:00"
        MapTracker.clear()
    }
    func eachSecond(timer: NSTimer) {
        seconds++
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        let secondsRunning = (secondsQuantity.description as NSString!).integerValue
        var secondsForMinutes:String
        if secondsRunning%60 < 10{
            secondsForMinutes = "0" + "\(secondsRunning%60)"
        }
        else{
            secondsForMinutes = "\(secondsRunning%60)"
        }

        if secondsRunning <= 9 {
            timeLabel.text = "0:0" + "\(secondsRunning)"

        }
        if secondsRunning >= 10 && secondsRunning < 60 {
            timeLabel.text = "0:" + "\(secondsRunning)"
        }
        else if secondsRunning >= 60{
            timeLabel.text = "\(secondsRunning/60)" + ":" + "\(secondsForMinutes)"
        }
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let distanceInFeetTemp = distance * 3.28084
        let distanceInMilesTemp = distanceInFeetTemp/5280
        let distanceInMiles = round(distanceInMilesTemp*100)/100
        distanceLabel.text = "\(distanceInMiles)"

        if distance == 0 {
            paceLabel.text = "0"
        }
        else{
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: (seconds/60) / distanceInMiles)
        paceLabel.text = paceQuantity.description
        }
    }
        
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func SaveRoute(sender: AnyObject) {
        var names:String?
        self.locationManager.stopUpdatingLocation()
        
        var locationarray = [CLLocationCoordinate2D]()
        for location in locations{
            locationarray.append(location.coordinate)
        }
        var encodedPath:String = encodeCoordinates(locationarray)
        var path:GMSPath = GMSPath(fromEncodedPath: encodedPath)
        var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
        var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
        var cameraPosition = MapTracker.cameraForBounds(camera, insets: insets)
        MapTracker.camera = cameraPosition
        
        var alert = UIAlertController(title: "New name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in

                let textField = alert.textFields![0]
                names = textField.text
                
               self.saveRun(names!)
                
                self.performSegueWithIdentifier(DetailSegueName, sender: nil)
                
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
        print(names)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var manager: CLLocationManager
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.activityType = .Fitness
        self.locationManager.requestAlwaysAuthorization()
        MapTracker.myLocationEnabled = true
        
        promptLabel.hidden = false
        timeLabel.hidden = true
        distanceLabel.hidden = true
        paceLabel.hidden = true
        stopButton.hidden = true
        staticLabelOne.hidden  = true
        staticLabelTwo.hidden  = true
        staticLabelThree.hidden  = true
        staticLabelFour.hidden  = true

        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            MapTracker.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            MapTracker.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
       
    }
  
}
// MARK: - MKMapViewDelegate


// MARK: - CLLocationManagerDelegate
extension RouteTracker {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            var path = GMSMutablePath()
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    for coordinate in coords{
                    path.addCoordinate(coordinate)
                        var polyline = GMSPolyline(path: path)

                    polyline.strokeWidth = 5.0
                    polyline.strokeColor = UIColor.blueColor()
                    polyline.map = MapTracker
                        var camera: GMSCameraPosition = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                        MapTracker.camera = camera


                    }
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}

// MARK: - UIActionSheetDelegate
//extension RouteTracker: UIActionSheetDelegate {
//    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
//        //save
//        if buttonIndex == 1 {
//            saveRun()
//            performSegueWithIdentifier(DetailSegueName, sender: nil)
//        }
//            //discard
//        else if buttonIndex == 2 {
//            navigationController?.popToRootViewControllerAnimated(true)
//        }
//    }
//}
//

