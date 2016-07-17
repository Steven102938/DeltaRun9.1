//
//  RequestsViewController.swift
//  Run
//
//  Created by Steven Li on 5/8/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RequestsViewController:UIViewController, UITableViewDelegate {
    
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RequestName = [String]()
    var RequestSenderId = [Double]()
    var RequestId = [Double]()
    var RequestMessage = [String]()
    var RequestRunDate = [String]()
    var RequestRunId = [Double]()
    var RequestFrom = [String]()
    var RequestImage = [String]()
    
    override func viewDidLoad() {
        clearRequests()
        //get user id from core data
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        var loginUserId = currentUser.userid
        var verificationIdTemp:String = currentUser.verificationid!
        var verificationIdTemp2:String = verificationIdTemp.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var verificationId:String = verificationIdTemp2.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        //execute server query
        print(verificationId)
        var runQuery:String = "http://jeber.me/requestquery.php?requestuserid=" + "\(loginUserId!)"
        var directionsURLString = NSURL(string: runQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print(dictionary)
        //take response and append to local array and add to coredata
        for run in dictionary!{
            let tempRequestName = run["requestname"]! as! String
            let tempRequestSenderId = run["senderid"]!!.doubleValue
            let tempRequestId = run["requestid"]!!.doubleValue
            let tempRequestMessage = run["requestmessage"]! as! String
            let tempRequestRunDate = run["dateforrun"]! as! String
            let tempRequestRunId = run["routeid"]!!.doubleValue
            let tempRequestFrom = run["sendername"]! as! String
            let tempRequestImage = run["requestimage"]! as! String
            self.RequestName.append(tempRequestName)
            self.RequestSenderId.append(tempRequestSenderId)
            self.RequestId.append(tempRequestId)
            self.RequestMessage.append(tempRequestMessage)
            self.RequestRunDate.append(tempRequestRunDate)
            self.RequestRunId.append(tempRequestRunId)
            self.RequestFrom.append(tempRequestFrom)
            self.RequestImage.append(tempRequestImage)
            
            let savedRun = NSEntityDescription.entityForName("Requests",
                inManagedObjectContext: managedObjectContext!)
            let requests = Requests(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
            requests.requestname = tempRequestName
            requests.requestfrom = tempRequestFrom
            requests.requestfromid = tempRequestSenderId
            requests.requestmessage = tempRequestMessage
            requests.requestrundate = tempRequestRunDate
            requests.requestrunid = tempRequestRunId
            requests.requestid = tempRequestId
            requests.requestimage = tempRequestImage
            var error: NSError?
            let request = NSFetchRequest(entityName: "NearbyRuns")
            
            do {
                try managedObjectContext!.save()
            } catch var error1 as NSError {
                error = error1
            }

        }
    }
    func clearRequests() {
            print("clearing")
            let request = NSFetchRequest(entityName: "Requests")
            var RequestData = (try! managedObjectContext!.executeFetchRequest(request)) as! [Requests]
            while RequestData.count != 0 {
                var count:Int = RequestData.count
                self.managedObjectContext!.deleteObject(RequestData.removeLast() as NSManagedObject)
                print(RequestData.count)
                do {
                    try self.managedObjectContext!.save()
                } catch _ {
                }
            }
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     
            var error: NSError?
            let request = NSFetchRequest(entityName: "Requests")
            var RequestData = (try! managedObjectContext?.executeFetchRequest(request)) as! [Requests]
            let routeCount = RequestData.count
        print(RequestData)
        print("the route count is" + "\(routeCount)")
            return routeCount
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> RequestCell
    {
            let identifier:String = "RequestReuse"
            let cell:RequestCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RequestCell
            var error: NSError?
            let request = NSFetchRequest(entityName: "Requests")
            var RequestData = (try! managedObjectContext?.executeFetchRequest(request)) as! [Requests]
            var requestCount = RequestData.count
            
            let RunInfoForTable = RequestData[indexPath.row]
        //labels
            cell.RequestName.text = RunInfoForTable.requestname
            cell.RequestMessage.text = RunInfoForTable.requestmessage
        //ImageDecode
            var decodedImage = RunInfoForTable.requestimage
            decodedImage = decodedImage!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            decodedImage = decodedImage!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let decodedData = NSData(base64EncodedString: decodedImage!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            var decodedimage = UIImage(data: decodedData!)
            cell.RequestRouteImage.image = decodedimage
        
        
//            cell.DetailSegue.setTitle("Info", forState: .Normal )
//            //            cell.runByLabel.hidden = true
//            
//            cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
//            
        
            return cell
    }
    
}

class RequestCell:UITableViewCell {
    
    @IBOutlet weak var RequestRouteImage: UIImageView!
    @IBOutlet weak var RequestName: UILabel!
    @IBOutlet weak var RequestFrom: UILabel!
    @IBOutlet weak var RequestDate: UILabel!
    @IBOutlet weak var RequestDistance: UILabel!
    @IBOutlet weak var RequestMessage: UILabel!
}