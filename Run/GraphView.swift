//
//  GraphView.swift
//  
//
//  Created by Steven Li on 9/25/15.
//
//

import Darwin
import Foundation
import UIKit
import CoreData
import GoogleMaps
@IBDesignable class GraphView: UIView {
    
    let managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    //var speedsArray = [Double]()
    
    //This is sample data to test the graph
    var speedsArray:[Double] = [4, 2, 6, 4, 5, 8, 3]


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
        var speed: Double
        
        for i in 2...arrayOfCoordinates.count {
            currentCoordinates = arrayOfCoordinates[i]
            pastCoordinates = arrayOfCoordinates[i-1]

            distance = calculateDistance(currentCoordinates, pastCoordinates: pastCoordinates)
            speed = calculateSpeed(distance)
            
            distancesArray.append(distance)
            //speedsArray.append(speed)
        }
        
        
        overlayPoints(speedsArray)
    }
    func overlayPoints(speedArray:[Double]) {
        
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
        //var radiusOfEarth = 20903520 //derived from radius of Earth in miles (in feet)
        
        let radiusOfEarth = 20902230 // derived from radius of the Earth in KM (in feet)
        let lat2 = toRadians(currentCoordinates.latitude)
        let lat1 = toRadians(pastCoordinates.latitude)
        let long2 = toRadians(currentCoordinates.longitude)
        let long1 = toRadians(pastCoordinates.longitude)
        
        let ΔφdividedBy2 = (lat2 - lat1) / 2
        let ΔλdividedBy2 = (long2 - long1) / 2
        let a = pow(sin(ΔφdividedBy2), 2) + cos(lat1) * cos(lat2) * pow(sin(ΔλdividedBy2), 2)
        
        let c = 2 * asin(sqrt(a))
        
        let distance = c * Double(radiusOfEarth)

        return distance //returns in feet
    }
    
    func toRadians(degrees: Double) -> Double {
        let DEG_TO_RAD = 0.017453292519943295769236907684886
        return degrees * DEG_TO_RAD
    }
    
    
    func calculateSpeed(distance: Double) -> Double {
        let rateOfLocationUpdates = 1.0 //second
        var speed = distance / rateOfLocationUpdates //in feet per second
        speed = speed / 5280 * 3600 //in miles per hour
        return speed
    }
    
    
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
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
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            [])
        //calculate the x point
        
        let margin:CGFloat = 20.0
        var columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.speedsArray.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        // calculate the y point
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = self.speedsArray.maxElement()
        var columnYPoint = { (graphPoint:Double) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        // draw the line graph
        
        UIColor.whiteColor().setFill()
        UIColor.whiteColor().setStroke()
        
        //set up the points line
        var graphPath = UIBezierPath()
        //go to start of line
        graphPath.moveToPoint(CGPoint(x:columnXPoint(0), y:columnYPoint(self.speedsArray[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<speedsArray.count {
            let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(self.speedsArray[i]))
            graphPath.addLineToPoint(nextPoint)
        }
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        CGContextSaveGState(context)
        
        //2 - make a copy of the path
        var clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLineToPoint(CGPoint(
            x: columnXPoint(speedsArray.count - 1),
            y:height))
        clippingPath.addLineToPoint(CGPoint(
            x:columnXPoint(0),
            y:height))
        clippingPath.closePath()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue!)
        startPoint = CGPoint(x:margin, y: highestYPoint)
        endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
        CGContextRestoreGState(context)
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        //Draw the circles on top of graph stroke
        for i in 0..<speedsArray.count {
            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(speedsArray[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalInRect:
                CGRect(origin: point,
                    size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
        //Draw horizontal graph lines on the top of everything
        var linePath = UIBezierPath()
        
        //top line
        linePath.moveToPoint(CGPoint(x:margin, y: topBorder))
        linePath.addLineToPoint(CGPoint(x: width - margin,
            y:topBorder))
        
        //center line
        linePath.moveToPoint(CGPoint(x:margin,
            y: graphHeight/2 + topBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.moveToPoint(CGPoint(x:margin,
            y:height - bottomBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
}