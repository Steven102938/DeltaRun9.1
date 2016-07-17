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
    var dataType = mainInstance.tableType
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        loadLabels()
        loadMap()
    }
    func loadLabels() {
        print(dataType)
        print(mainInstance.routeNumber)
        if dataType == "RunInfo"{
            var error: NSError?
            let request = NSFetchRequest(entityName: dataType!)
            var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
            let routeNumber = mainInstance.routeNumber
            
            let currentdata = RunInfoData[routeNumber!]
            let distance = currentdata.distance as Double
            let seconds = currentdata.duration as Double
            print(currentdata)
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
            distanceLabel.text = "\(distance)"
        }
        if dataType == "NearbyRuns" {
            var error: NSError?
            let request = NSFetchRequest(entityName: dataType!)
            var RunInfoData:[NearbyRuns] = (try! managedObjectContext?.executeFetchRequest(request)) as! [NearbyRuns]
            let routeNumber = mainInstance.routeNumber
            
            let currentdata:NearbyRuns = RunInfoData[routeNumber!]

            let distance = currentdata.nearbydistance as! Double
            let seconds = currentdata.nearbyduration as! Double
            print(currentdata)
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
            distanceLabel.text = "\(distance)"

        }
        if dataType == "FriendRuns" {
            var error: NSError?
            let request = NSFetchRequest(entityName: dataType!)
            var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [FriendRuns]
            let routeNumber = mainInstance.routeNumber
            
            let currentdata = RunInfoData[routeNumber!]
            let distance = currentdata.frienddistance as! Double
            let seconds = currentdata.friendduration as! Double
            print(currentdata)
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
            distanceLabel.text = "\(distance)"

        }
    }
    func loadMap() {
        if dataType == "RunInfo"{
        var error: NSError?
        var request = NSFetchRequest(entityName: dataType!)
        var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        var routeNumber = mainInstance.routeNumber

        let previousRun = RunInfoData[routeNumber!]
        
        var path:GMSPath = GMSPath(fromEncodedPath: previousRun.polyline)
        var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
        var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
        var cameraPosition = mapView.cameraForBounds(camera, insets: insets)
        mapView.camera = cameraPosition
        print("\(previousRun.polyline)")
       var coordinates:[CLLocationCoordinate2D] = decodePolyline(previousRun.polyline)!
        print(previousRun)
        var routePolyline = GMSPolyline(path: path)
        routePolyline.map = mapView
        }
        if dataType == "NearbyRuns"{
            var error: NSError?
            var request = NSFetchRequest(entityName: dataType!)
            var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [NearbyRuns]
            var routeNumber = mainInstance.routeNumber
            
            let previousRun = RunInfoData[routeNumber!]
            
            var path:GMSPath = GMSPath(fromEncodedPath: previousRun.nearbypolyline)
            var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
            var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
            var cameraPosition = mapView.cameraForBounds(camera, insets: insets)
            mapView.camera = cameraPosition
            print("\(previousRun.nearbypolyline)")
            var coordinates:[CLLocationCoordinate2D] = decodePolyline(previousRun.nearbypolyline!)!
            print(previousRun)
            var routePolyline = GMSPolyline(path: path)
            routePolyline.map = mapView
        }
        if dataType == "FriendRuns" {
            var error: NSError?
            var request = NSFetchRequest(entityName: dataType!)
            var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [FriendRuns]
            var routeNumber = mainInstance.routeNumber
            
            let previousRun = RunInfoData[routeNumber!]
            
            var path:GMSPath = GMSPath(fromEncodedPath: previousRun.friendpolyline)
            var camera:GMSCoordinateBounds = GMSCoordinateBounds(path: path)
            var insets:UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
            var cameraPosition = mapView.cameraForBounds(camera, insets: insets)
            mapView.camera = cameraPosition
            print("\(previousRun.friendpolyline)")
            var coordinates:[CLLocationCoordinate2D] = decodePolyline(previousRun.friendpolyline!)!
            print(previousRun)
            var routePolyline = GMSPolyline(path: path)
            routePolyline.map = mapView
        }
        //        var previousRunLocations = previousRun.locations
        //        var locationsArray = Array(previousRunLocations) as! [Location]
        //        var arrayOfCoordinates = [CLLocationCoordinate2D]()
        //        for location in locationsArray{
        //            let tempCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
        //            arrayOfCoordinates.append(tempCoordinate)
        //        }
        //        var encodedPath:String = encodeCoordinates(arrayOfCoordinates)

//            if previousRun.locations.count > 0 {
//                
//                let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: locationsArray)
//                for polylines in colorSegments {
//                    polylines.map = mapView
//                    polylines.strokeColor = polylines.color
//                }
        
//            } else {
//                // No locations were found!
//                mapView.hidden = true
//                
//                UIAlertView(title: "Error",
//                    message: "Sorry, this run has no locations saved",
//                    delegate:nil,
//                    cancelButtonTitle: "OK").show()
//            }
        }
    
    
}


