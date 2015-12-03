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
class RouteHistory: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableViewObject: UITableView!
   
    
    var number = 1
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    var deleteRouteIndexPath: NSIndexPath? = nil
    var RunInfoSegue = "RunInfo"
    var routeNames = [String]()
    var routeDuration = [Int]()
    var routeDistance = [Int]()
    var routeDaterun = [String]()
    var routeCoordinates = [String]()
    var routeRunId = [String]()
    var routeImage = [String]()
    struct global {
        static var tempNumber: Int?
    }
    
    override func viewDidAppear(animated: Bool) {
    
    
    let userRequest = NSFetchRequest(entityName: "User")
    var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
    var currentUser = userInfoData.removeLast()
    var loginUserId = currentUser.userid
    var verificationIdTemp:String = currentUser.verificationid!
    var verificationIdTemp2:String = verificationIdTemp.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    var verificationId:String = verificationIdTemp2.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        print(verificationId)
        var runQuery:String = "http://192.168.1.119/runquery.php?userid=" + "\(loginUserId!)" + "&verificationid=" + "\(verificationId)"
        var directionsURLString = NSURL(string: runQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        for user in dictionary{
        let tempName = user["name"]! as! String
        let tempDuration = user["duration"]!!.integerValue
        let tempDistance = user["distance"]!!.integerValue
        let tempDaterun = user["daterun"]! as! String
        let tempCoordinates = user["coordinates"]! as! String
        let tempRunId = user["runid"]! as! String
        let tempImageData = user["routeimage"] as! String
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
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        let routeCount = RunInfoData.count

        return routeCount
    
    }
   
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> mapCell
        {
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
            print(decodedData)
            var decodedimage = UIImage(data: decodedData!)
            cell.mapPreview.image = decodedimage
            cell.DetailSegue.setTitle("Info", forState: .Normal )

       
           cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
 
        return cell
        
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