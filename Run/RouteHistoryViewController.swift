//
//  RouteHistory.swift
//  Run
//
//  Created by Steven Li on 8/20/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Darwin
import CoreData
import GoogleMaps
import Foundation

class RouteHistory: UIViewController, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableViewObject: UITableView!
    @IBOutlet weak var changeRuns: UISegmentedControl!
   
    
    var number = 1
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    var deleteRouteIndexPath: NSIndexPath? = nil
    var RunInfoSegue = "RunInfo"
    var tableViewType = "Coredata"
    var routeNames = [String]()
    var routeDuration = [Int]()
    var routeDistance = [Int]()
    var routeDaterun = [String]()
    var routeCoordinates = [String]()
    var routeRunId = [String]()
    var routeImage = [String]()
    var nearbyRouteNames = [String]()
    var nearbyRouteDuration = [Int]()
    var nearbyRouteDistance = [Int]()
    var nearbyRouteDaterun = [String]()
    var nearbyRouteCoordinates = [String]()
    var nearbyRouteRunId = [String]()
    var nearbyRouteImage = [String]()
    let locationManager = CLLocationManager()
    var loadCoordinates:CLLocationCoordinate2D?
    struct global {
        static var tempNumber: Int?
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

    
    let userRequest = NSFetchRequest(entityName: "User")
    var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
    var currentUser = userInfoData.removeLast()
    var loginUserId = currentUser.userid
    var verificationIdTemp:String = currentUser.verificationid!
    var verificationIdTemp2:String = verificationIdTemp.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    var verificationId:String = verificationIdTemp2.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        print(verificationId)
        var runQuery:String = "http://192.168.1.133/runquery.php?userid=" + "\(loginUserId!)" + "&verificationid=" + "\(verificationId)"
        var directionsURLString = NSURL(string: runQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        for run in dictionary{
        let tempName = run["name"]! as! String
        let tempDuration = run["duration"]!!.integerValue
        let tempDistance = run["distance"]!!.integerValue
        let tempDaterun = run["daterun"]! as! String
        let tempCoordinates = run["coordinates"]! as! String
        let tempRunId = run["runid"]! as! String
        let tempImageData = run["routeimage"] as! String
            self.routeImage.append(tempImageData)
            self.routeNames.append(tempName)
            self.routeDuration.append(tempDuration)
            self.routeDistance.append(tempDistance)
            self.routeDaterun.append(tempDaterun)
            self.routeCoordinates.append(tempCoordinates)
            self.routeRunId.append(tempRunId)
        }

    
        tableViewObject.reloadData()
        tableViewObject.reloadInputViews()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch changeRuns.selectedSegmentIndex
        {
        case 0:
            print("1")
            tableViewType = "Coredata"
            tableViewObject.reloadData()
            tableViewObject.reloadInputViews()
            //show popular view
        case 1:
            //clear nearbytable
            self.nearbyRouteImage.removeAll()
            self.nearbyRouteNames.removeAll()
            self.nearbyRouteDuration.removeAll()
            self.nearbyRouteDistance.removeAll()
            self.nearbyRouteDaterun.removeAll()
            self.nearbyRouteCoordinates.removeAll()
            self.nearbyRouteRunId.removeAll()
           
            print("2")
            tableViewType = "nearby"
            loadNearbyRuns()
            tableViewObject.reloadData()
            tableViewObject.reloadInputViews()
            //show history view
        case 2:
            print("3")
        default:
            break;
        }
    }

 func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            var error: NSError?
            let request = NSFetchRequest(entityName: "RunInfo")
            RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
            // remove the deleted item from the model
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            context.deleteObject(RunInfoData[indexPath.row] as NSManagedObject)
            RunInfoData.removeAtIndex(indexPath.row)
            do {
                try context.save()
            } catch _ {
            }
            
            //tableView.reloadData()
            // remove the deleted item from the `UITableView`
            self.tableViewObject.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
         
        default:
            return
            
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableViewType == "Coredata" {
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        let routeCount = RunInfoData.count
        return routeCount
        }else{
         return self.nearbyRouteRunId.count
        }
    }
   
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> mapCell
        {
            if tableViewType == "Coredata" {
        let identifier:String = "MapReuse"
        let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        var routeCount = RunInfoData.count
 
            let RunInfoForTable = RunInfoData[indexPath.row]
            cell.routeName.text = RunInfoForTable.name
            var decodedImage = RunInfoForTable.image
            decodedImage = decodedImage.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            decodedImage = decodedImage.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)


            let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            var decodedimage = UIImage(data: decodedData!)
            cell.mapPreview.image = decodedimage
            cell.DetailSegue.setTitle("Info", forState: .Normal )

       
           cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
 
        return cell
            }
            else{
                let identifier:String = "MapReuse"
                let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
                               cell.routeName.text = nearbyRouteNames[indexPath.row]
                var decodedImage = nearbyRouteImage[indexPath.row]
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                var decodedimage = UIImage(data: decodedData!)
                cell.mapPreview.image = decodedimage
                cell.DetailSegue.setTitle("Info", forState: .Normal )
                cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
                
                return cell
                
            }
    }
    func loadNearbyRuns() {
        var searchRange = 1
        var arrayInt:[Double] = [0.5/138,1/138,2/138,5/138]
        var originlatitude = loadCoordinates?.latitude
        var originlongitude = loadCoordinates?.longitude
        var nearbyQuery:String = "http://192.168.1.133/nearbyquery.php?latituderangeone=" + "\(originlatitude! - arrayInt[searchRange])" + "&latituderangetwo=" + "\(originlatitude! + arrayInt[searchRange])" + "&longituderangeone=" + "\(originlongitude! - arrayInt[searchRange])" + "&longituderangetwo=" + "\(originlongitude! + arrayInt[searchRange])"
        print(nearbyQuery)
        var directionsURLString = NSURL(string: nearbyQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        for run in dictionary{
            let tempName = run["name"]! as! String
            let tempDuration = run["duration"]!!.integerValue
            let tempDistance = run["distance"]!!.integerValue
            let tempDaterun = run["daterun"]! as! String
            let tempCoordinates = run["coordinates"]! as! String
            let tempRunId = run["runid"]! as! String
            let tempImageData = run["routeimage"] as! String
            self.nearbyRouteImage.append(tempImageData)
            self.nearbyRouteNames.append(tempName)
            self.nearbyRouteDuration.append(tempDuration)
            self.nearbyRouteDistance.append(tempDistance)
            self.nearbyRouteDaterun.append(tempDaterun)
            self.nearbyRouteCoordinates.append(tempCoordinates)
            self.nearbyRouteRunId.append(tempRunId)
        }
        for nearbyRoute in routeRunId{
            if nearbyRouteRunId.contains(nearbyRoute){
                print("match")
               nearbyRouteRunId = nearbyRouteRunId.filter(){ $0 != nearbyRoute }
            }
        }
    }
    func locationManager(manager: CLLocationManager, var didUpdateLocations locations: [CLLocation]) {
        print(locations)
        var firstLocation = locations.removeFirst()
        loadCoordinates = firstLocation.coordinate
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
func pressed(sender: UIButton!) {
    
    let button = sender as UIButton
    let view = button.superview!
    let cell = view.superview as! mapCell
    let indexPath = tableViewObject.indexPathForCell(cell)
    let row = indexPath?.row
    
    print(row)
    mainInstance.routeNumber = row! + 1
    self.performSegueWithIdentifier(RunInfoSegue, sender: nil)

        print("yourButton was pressed")
    }
 
    
}

class mapCell:UITableViewCell {
    
   
   
    @IBOutlet weak var mapPreview: UIImageView!
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var DetailSegue: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
extension RouteDatabase{
    
}
extension UserDatabase{
    
}