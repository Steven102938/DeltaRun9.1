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