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
    var tableViewType = "RunInfo"
    var routeNames = [String]()
    var routeDuration = [Int]()
    var routeDistance = [Double]()
    var routeDaterun = [String]()
    var routeCoordinates = [String]()
    var routeRunId = [Int]()
    var routeImage = [String]()
    
    var nearbyRouteNames = [String]()
    var nearbyRouteDuration = [Int]()
    var nearbyRouteDistance = [Double]()
    var nearbyRouteDaterun = [String]()
    var nearbyRouteCoordinates = [String]()
    var nearbyRouteRunId = [Int]()
    var nearbyRouteImage = [String]()
    var nearbyRunBy = [String]()
    
    var friendRunBy = [String]()
    var friendRouteNames = [String]()
    var friendRouteDuration = [Int]()
    var friendRouteDistance = [Double]()
    var friendRouteDaterun = [String]()
    var friendRouteCoordinates = [String]()
    var friendRouteRunId = [Int]()
    var friendRouteImage = [String]()
    
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
        var runQuery:String = "http://jeber.me/runquery.php?userid=" + "\(loginUserId!)" + "&verificationid=" + "\(verificationId)"
        var directionsURLString = NSURL(string: runQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        for run in dictionary{
        let tempName = run["name"]! as! String
        let tempDuration = run["duration"]!!.integerValue
        let tempDistance = run["distance"]!!.doubleValue
        let tempDaterun = run["daterun"]! as! String
        let tempCoordinates = run["coordinates"]! as! String
        let tempRunId = run["runid"]!!.integerValue
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
            tableViewType = "RunInfo"
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
            self.nearbyRunBy.removeAll()
            print("2")
            tableViewType = "NearbyRuns"
            loadNearbyRuns()
            tableViewObject.reloadData()
            tableViewObject.reloadInputViews()
            //show history view
        case 2:
            print("3")
            self.friendRouteImage.removeAll()
            self.friendRouteNames.removeAll()
            self.friendRouteDuration.removeAll()
            self.friendRouteDistance.removeAll()
            self.friendRouteDaterun.removeAll()
            self.friendRouteCoordinates.removeAll()
            self.friendRouteRunId.removeAll()
            self.friendRunBy.removeAll()
            tableViewType = "FriendRuns"
            loadFriendRuns()
            tableViewObject.reloadData()
            tableViewObject.reloadInputViews()
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
        if tableViewType == "RunInfo" {
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        let routeCount = RunInfoData.count
        return routeCount
        }else if tableViewType == "NearbyRuns"{
         return self.nearbyRouteRunId.count
        }
        else {
            //friendrun
            return self.friendRouteRunId.count
        }

        
    }
   
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> mapCell
        {
            if tableViewType == "RunInfo" {
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

                print(decodedImage)
            let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            var decodedimage = UIImage(data: decodedData!)
            cell.mapPreview.image = decodedimage
            cell.DetailSegue.setTitle("Info", forState: .Normal )
//            cell.runByLabel.hidden = true
       
           cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
 
        return cell
            }
            if tableViewType == "NearbyRuns"{
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
//                cell.runByLabel.text = nearbyRunBy[indexPath.row]

                return cell
                
            }
            if tableViewType == "FriendRuns"{
                let identifier:String = "MapReuse"
                let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
                if friendRouteNames.isEmpty {
                    let identifier:String = "MapReuse"
                    let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
                    return cell
                    print("empty")
                }
                else{
                    print("stuff")
                cell.routeName.text = friendRouteNames[indexPath.row]
                var decodedImage = friendRouteImage[indexPath.row]
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                var decodedimage = UIImage(data: decodedData!)
                cell.mapPreview.image = decodedimage
                cell.DetailSegue.setTitle("Info", forState: .Normal )
                cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
//                cell.runByLabel.text = friendRunBy[indexPath.row]
                return cell
                }
            }
            else{
                print("broken")
                let identifier:String = "MapReuse"
                let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
                return cell
            }
    }
    func loadFriendRuns() {
        
        let request = NSFetchRequest(entityName: "FriendRuns")
        var UserData = (try! managedObjectContext!.executeFetchRequest(request)) as! [FriendRuns]
        print(UserData.count)
        while UserData.count != 0 {
            var count:Int = UserData.count
            self.managedObjectContext!.deleteObject(UserData.removeLast() as NSManagedObject)
            print(UserData.count)
            do {
                try self.managedObjectContext!.save()
            } catch _ {
            }
        }
        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        var friendString = currentUser.friends
        
          var friendQuery:String = "http://jeber.me/friendrunquery.php?userid=" + "\(friendString)"
        print(friendQuery)
        var friendQueryWeb = friendQuery.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)

        var directionsURLString = NSURL(string: friendQueryWeb)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        for run in dictionary{
            let tempName = run["name"]! as! String
            let tempDuration = run["duration"]!!.integerValue
            let tempDistance = run["distance"]!!.doubleValue
            let tempDaterun = run["daterun"]! as! String
            let tempCoordinates = run["coordinates"]! as! String
            let tempRunId = run["runid"]!!.integerValue
            let tempImageData = run["routeimage"] as! String
            let tempRunBy = run["runby"] as! String
            let tempUserId = run["useridkey"]!!.integerValue
            
            self.friendRunBy.append(tempRunBy)
            self.friendRouteImage.append(tempImageData)
            self.friendRouteNames.append(tempName)
            self.friendRouteDuration.append(tempDuration)
            self.friendRouteDistance.append(tempDistance)
            self.friendRouteDaterun.append(tempDaterun)
            self.friendRouteCoordinates.append(tempCoordinates)
            self.friendRouteRunId.append(tempRunId)
            
            let savedRun = NSEntityDescription.entityForName("FriendRuns",
                inManagedObjectContext: managedObjectContext!)
            let FriendRun = FriendRuns(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
            FriendRun.friendrunby = tempRunBy
            FriendRun.friendimage = tempImageData
            FriendRun.frienddistance = tempDistance
            FriendRun.friendduration = tempDuration
            FriendRun.friendname = tempName
            FriendRun.friendpolyline = tempCoordinates
            FriendRun.friendrunid = tempRunId
            FriendRun.friendtimestamp = tempDaterun
            FriendRun.friendid = tempUserId
            
            var error: NSError?
            let request = NSFetchRequest(entityName: "FriendRuns")
            
            do {
                try managedObjectContext!.save()
            } catch var error1 as NSError {
                error = error1
            }

    }
    }
    func loadNearbyRuns() {
        
            let request = NSFetchRequest(entityName: "NearbyRuns")
            var UserData = (try! managedObjectContext!.executeFetchRequest(request)) as! [NearbyRuns]
            print(UserData.count)
            while UserData.count != 0 {
                var count:Int = UserData.count
                self.managedObjectContext!.deleteObject(UserData.removeLast() as NSManagedObject)
                print(UserData.count)
                do {
                    try self.managedObjectContext!.save()
                } catch _ {
                }
            }
        
        
        var searchRange = 1
        var arrayInt:[Double] = [0.5/138,1/138,2/138,5/138]
        var originlatitude = loadCoordinates?.latitude
        var originlongitude = loadCoordinates?.longitude
    if nearbyRouteRunId.count <= 10 && searchRange <= 4{
        var nearbyQuery:String = "http://jeber.me/nearbyquery.php?latituderangeone=" + "\(originlatitude! - arrayInt[searchRange])" + "&latituderangetwo=" + "\(originlatitude! + arrayInt[searchRange])" + "&longituderangeone=" + "\(originlongitude! - arrayInt[searchRange])" + "&longituderangetwo=" + "\(originlongitude! + arrayInt[searchRange])"
        print(nearbyQuery)
        var directionsURLString = NSURL(string: nearbyQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        for run in dictionary{
            let tempName = run["name"]! as! String
            let tempDuration = run["duration"]!!.integerValue
            let tempDistance = run["distance"]!!.doubleValue
            let tempDaterun = run["daterun"]! as! String
            let tempCoordinates = run["coordinates"]! as! String
            let tempRunId = run["runid"]!!.integerValue
            let tempImageData = run["routeimage"] as! String
            let tempRunBy = run["runby"] as! String
            if routeRunId.contains(tempRunId) {
                
            }
            
            else{
                print("doesnotinfringe" + "\(tempDuration)")
            self.nearbyRouteImage.append(tempImageData)
            self.nearbyRouteNames.append(tempName)
            self.nearbyRouteDuration.append(tempDuration)
            self.nearbyRouteDistance.append(tempDistance)
            self.nearbyRouteDaterun.append(tempDaterun)
            self.nearbyRouteCoordinates.append(tempCoordinates)
            self.nearbyRouteRunId.append(tempRunId)
            self.nearbyRunBy.append(tempRunBy)
                
            let savedRun = NSEntityDescription.entityForName("NearbyRuns",
                inManagedObjectContext: managedObjectContext!)
            let nearbyRun = NearbyRuns(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
            nearbyRun.nearbyimage = tempImageData
            nearbyRun.nearbydistance = tempDistance
            nearbyRun.nearbyduration = tempDuration
            nearbyRun.nearbyname = tempName
            nearbyRun.nearbypolyline = tempCoordinates
            nearbyRun.nearbyrunid = tempRunId
            nearbyRun.nearbytimestamp = tempDaterun
            nearbyRun.nearbyrunby = tempRunBy
            var error: NSError?
            let request = NSFetchRequest(entityName: "NearbyRuns")
            
            do {
                try managedObjectContext!.save()
            } catch var error1 as NSError {
                error = error1
            }
            searchRange++
            }
            }
        }
//        for nearbyRoute in routeRunId{
//            print(nearbyRoute)
//            print(nearbyRouteRunId)
//            if nearbyRouteRunId.contains(nearbyRoute){
//                print("match")
//                print(nearbyRoute)
//                var placeInArray = nearbyRouteRunId.indexOf(nearbyRoute)
//                nearbyRouteRunId = nearbyRouteRunId.filter(){ $0 != nearbyRoute }
//                nearbyRouteCoordinates.removeAtIndex(placeInArray!)
//                nearbyRouteDaterun.removeAtIndex(placeInArray!)
//                nearbyRouteDistance.removeAtIndex(placeInArray!)
//                nearbyRouteDuration.removeAtIndex(placeInArray!)
//                nearbyRouteNames.removeAtIndex(placeInArray!)
//                nearbyRouteImage.removeAtIndex(placeInArray!)
//                print(nearbyRouteRunId)
//
//            }
//        }
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
    mainInstance.routeNumber = row!
    mainInstance.tableType = self.tableViewType
    self.performSegueWithIdentifier(RunInfoSegue, sender: nil)

        print("yourButton was pressed")
    }
 
    
}

class mapCell:UITableViewCell {
    
   
//    @IBOutlet weak var runByLabel: UILabel!
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