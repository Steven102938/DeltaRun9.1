//
//  GraphView.swift
//  
//
//  Created by Steven Li on 9/25/15.
//
//

import Foundation
import UIKit
import CoreData
import GoogleMaps
@IBDesignable class GraphView: UIView {
    
    let managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    
    func viewDidLoad() {
 
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
        
        var distancesArray = [Double]()
        var currentCoordinates: CLLocationCoordinate2D
        var pastCoordinates: CLLocationCoordinate2D
        var distance: Double
        
        for i in 2...arrayOfCoordinates.count {
            currentCoordinates = arrayOfCoordinates[i]
            pastCoordinates = arrayOfCoordinates[i-1]
            
            distance = calculateDistance(currentCoordinates, pastCoordinates: pastCoordinates)
            
            distancesArray.append(distance)
            
        }
    }

    func calculateDistance(currentCoordinates: CLLocationCoordinate2D, pastCoordinates: CLLocationCoordinate2D) -> Double {
        /*
        Haversine formula:
        a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
        c = 2 ⋅ atan2( √a, √(1−a) )
        d = R ⋅ c
        where	φ is latitude, λ is longitude, R is earth’s radius (mean radius = 6,371km);
        angles need to be in radians
        */
        
        let radiusOfEarth = 20902230 //feet
        
        let lat1 = pastCoordinates.latitude
        let lat2 = currentCoordinates.latitude
        let long1 = pastCoordinates.longitude
        let long2 = currentCoordinates.longitude
        
        let ΔφdividedBy2 = (lat2 - lat1) / 2
        let ΔλdividedBy2 = (long2 - long1) / 2
        let a = pow(sin(ΔφdividedBy2), 2) + cos(lat1) * cos(lat2) * pow(sin(ΔλdividedBy2), 2)
        
        let c = 2 * asin(sqrt(a))
        
        let distance = c * Double(radiusOfEarth)
        return distance
    }
    
    func toRadians(degrees: Double) -> Double {
        let DEG_TO_RAD = 0.017453292519943295769236907684886
        return degrees * DEG_TO_RAD
    }
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    override func drawRect(rect: CGRect) {
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        //6 - draw the gradient
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            [])
        
        
    }
}