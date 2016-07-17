//
//  RunForRequestViewController.swift
//  Run
//
//  Created by Steven Li on 3/31/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RunForRequestViewController: UIViewController,UITableViewDelegate {
    
    @IBOutlet weak var runRequestTableView: UITableView!
    
    var number = 1
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    var deleteRouteIndexPath: NSIndexPath? = nil
    var RunRequestBackSegue = "RunRequestBackSegue"
    var routeNames = [String]()
    var routeDuration = [Int]()
    var routeDistance = [Double]()
    var routeDaterun = [String]()
    var routeCoordinates = [String]()
    var routeRunId = [Int]()
    var routeImage = [String]()
    var routeNumber = mainInstance.routeNumber

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
            self.runRequestTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
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
        print("routecount=" + "\(routeCount)" )
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> RunRequestCell
    {
            let identifier:String = "RunRequest"
            let cell:RunRequestCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RunRequestCell
            var error: NSError?
            let request = NSFetchRequest(entityName: "RunInfo")
            RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
            var routeCount = RunInfoData.count
            
            let RunInfoForTable = RunInfoData[indexPath.row]
            cell.routeName.text = RunInfoForTable.name
            var decodedImage = RunInfoForTable.image
            decodedImage = decodedImage.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            decodedImage = decodedImage.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
//            print(decodedImage)
            let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            var decodedimage = UIImage(data: decodedData!)
            cell.mapPreview.image = decodedimage
            cell.DetailSegue.setTitle("Select", forState: .Normal )
            //            cell.runByLabel.hidden = true
            
            cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
            
            return cell
            
    }
    override func viewDidLoad() {
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
//        print(dictionary)
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
    }
    func pressed(sender: UIButton!) {
        
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! RunRequestCell
        let indexPath = runRequestTableView.indexPathForCell(cell)
        let row = indexPath?.row
        let routeNumber = routeRunId[row!]
        let routeName = routeNames[row!]
        print("row is " + "\(row)")
        print("routenumber " + "\(routeNumber)")
        
        mainInstance.routeNumber = routeNumber
        mainInstance.globalString = routeName
//        self.performSegueWithIdentifier(RunRequestBackSegue, sender: nil)
        self.dismissViewControllerAnimated(true, completion: nil);

        navigationController?.popViewControllerAnimated(true)
        print("yourButton was pressed")
    }
    
}
class RunRequestCell:UITableViewCell {
    
    
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
