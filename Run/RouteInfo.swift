//
//  RouteInfo.swift
//  Run
//
//  Created by Steven Li on 9/25/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import CoreData
import CoreLocation
import HealthKit


class RouteInfo: UIViewController {

    let managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        loadLabels()
        loadMap()
    }
    func loadLabels() {
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        let routeNumber = mainInstance.routeNumber
       
        let currentdata = RunInfoData[routeNumber! - 1]
        let distance = currentdata.distance as Double
        let seconds = currentdata.duration as Double
        
        if distance == 0 {
            paceLabel.text = "Pace:0"
        }
        else{
            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
            paceLabel.text = "Pace: " + paceQuantity.description
        }
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        let secondsRunning = (secondsQuantity.description as NSString!).integerValue
        if secondsRunning <= 60 {
            timeLabel.text = "Time: " + secondsQuantity.description
        }
        else if secondsRunning >= 60{
            timeLabel.text = "\(secondsRunning/60)" + "m" + "\(secondsRunning%60)" + "s"
        }
    }
    func loadMap() {
        var error: NSError?
        var request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        var routeNumber = mainInstance.routeNumber

        let previousRun = RunInfoData[routeNumber! - 1]
        var previousRunLocations = previousRun.locations
        var locationsArray = Array(previousRunLocations) as! [Location]
        var arrayOfCoordinates = [CLLocationCoordinate2D]()
        for location in locationsArray{
            let tempCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
            arrayOfCoordinates.append(tempCoordinate)
        }
        var encodedPath:String = encodeCoordinates(arrayOfCoordinates)
        var path:GMSPath = GMSPath(fromEncodedPath: encodedPath)
        var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
        var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
        var cameraPosition = mapView.cameraForBounds(camera, insets: insets)
        mapView.camera = cameraPosition
            if previousRun.locations.count > 0 {
                
                let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: locationsArray)
                for polylines in colorSegments {
                    polylines.map = mapView
                    polylines.strokeColor = polylines.color
                }
                
            } else {
                // No locations were found!
                mapView.hidden = true
                
                UIAlertView(title: "Error",
                    message: "Sorry, this run has no locations saved",
                    delegate:nil,
                    cancelButtonTitle: "OK").show()
            }
        }
    
    
}


