//
//  FriendViewController.swift
//  Run
//
//  Created by Steven Li on 1/29/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FriendInfoViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var PastRuns: UITableView!
    
    let managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var friendRuns = [FriendRuns]()
    var FriendInfoSegue = "FriendInfo"
    override func viewDidLoad() {
        print("viewload ")

        var error: NSError?
        var request = NSFetchRequest(entityName: "FriendRuns")
        var RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [FriendRuns]
        
        print(RunInfoData)

        for runs in RunInfoData{
         print( runs.friendid)
        print(mainInstance.friendId)
            if runs.friendid == mainInstance.friendId{
                friendRuns.append(runs)
            }
        }
        PastRuns.reloadData()
        PastRuns.reloadInputViews()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print(friendRuns.count)
        return friendRuns.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FriendRunCell
    {
        
        let identifier:String = "FriendRunCell"
           let cell:FriendRunCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendRunCell
        print(" load ")
            let friendRunInfoForTable = friendRuns[indexPath.row]
            cell.runName.text = friendRunInfoForTable.friendname
        //change runname to route name
//            var decodedImage = friendRunInfoForTable.friendimage
//            decodedImage = decodedImage!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            decodedImage = decodedImage!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            let decodedData = NSData(base64EncodedString: decodedImage!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
//            var decodedimage = UIImage(data: decodedData!)
//            cell.mapPreview.image = decodedimage
        
            cell.detailSegue.setTitle("Info", forState: .Normal )
            //            cell.runByLabel.hidden = true
            
            cell.detailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
            
            return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    func pressed(sender: UIButton!) {
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! FriendRunCell
        let indexPath = PastRuns.indexPathForCell(cell)
        let row = indexPath?.row
        

        mainInstance.routeNumber = row!
        mainInstance.tableType = "FriendRuns"
        print("yourButton was pressed")
        self.performSegueWithIdentifier(FriendInfoSegue, sender: nil)

    }
}

class FriendRunCell:UITableViewCell {
    
    
    //    @IBOutlet weak var runByLabel: UILabel!
//    @IBOutlet weak var mapPreview: UIImageView!
    @IBOutlet weak var runName: UILabel!
    @IBOutlet weak var detailSegue: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
