//
//  FriendForRequestViewController.swift
//  Run
//
//  Created by Steven Li on 4/9/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class FriendForRequestViewController: UIViewController, UITableViewDelegate{
    
    @IBOutlet weak var FriendRequestTableView: UITableView!
    
    var friendString:String?
    var userIdArray: [Int] = []
    var userNameArray: [String] = []
    var friendArray: [String] = []
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(userNameArray.count)
        return userNameArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FriendRequestInfoCell {
        let identifier:String = "FriendRequestInfoCell"
        let cell:FriendRequestInfoCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendRequestInfoCell
        
        cell.NameRequestLabel.text = self.userNameArray[indexPath.row]
        print(cell.NameRequestLabel?.text)
        cell.SelectButton.tag = indexPath.row
        cell.SelectButton.addTarget(self, action: "friendSelect:", forControlEvents: .TouchUpInside)
        cell.DeselectButton.tag = indexPath.row
        cell.DeselectButton.addTarget(self, action: "friendDeselect:", forControlEvents: .TouchUpInside)
        
        var cellUserId:Int = self.userIdArray[indexPath.row]
        if mainInstance.globalArray.contains(cellUserId) {
            cell.DeselectButton.hidden = false
            cell.SelectButton.hidden = true
        }
        else {
            cell.DeselectButton.hidden = true
            cell.SelectButton.hidden = false

        }
        let currentId = userIdArray[indexPath.row]
        
        return cell
    }
    
    
    override func viewDidLoad() {
        FriendRequestTableView.delegate = self
        //coredata fetch
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        friendString = currentUser.friends
        
        
        
        //take string of friend ids and query to server
        friendArray = friendString!.characters.split{$0 == " "}.map(String.init)
        var webFriendString = friendString!.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var userIdQuery:String = "http://jeber.me/useridquery.php?userid=" + "\(webFriendString)"
        print(userIdQuery)
        var userURLString = NSURL(string: userIdQuery)
        if userURLString != nil {
            let data = NSData(contentsOfURL: userURLString!)
            let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
            print(dictionary)
            for user in dictionary{
                let tempUserName = user["username"]! as! String
                let tempUserId = user["userid"]!!.integerValue
                self.userIdArray.append(tempUserId)
                self.userNameArray.append(tempUserName)
            }
        }
        
    }
    func friendSelect(sender: UIButton!) {
        
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! FriendRequestInfoCell
        let indexPath = FriendRequestTableView.indexPathForCell(cell)
        let row = indexPath?.row
        let friendId = userIdArray[row!]
        cell.SelectButton.hidden = true
        cell.DeselectButton.hidden = false

        mainInstance.globalArray.append(friendId)
        
        print("yourButton was pressed")
    }
    func friendDeselect(sender: UIButton!) {
        
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! FriendRequestInfoCell
        let indexPath = FriendRequestTableView.indexPathForCell(cell)
        let row = indexPath?.row
        let friendId = userIdArray[row!]
        cell.SelectButton.hidden = false
        cell.DeselectButton.hidden = true


        var friendIdIndex = mainInstance.globalArray.indexOf(friendId)
        mainInstance.globalArray.removeAtIndex(friendIdIndex!)
        
        print("yourButton was pressed")
    }
}
class FriendRequestInfoCell: UITableViewCell {
    
    @IBOutlet weak var NameRequestLabel: UILabel!
    @IBOutlet weak var SelectButton: UIButton!

    @IBOutlet weak var DeselectButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}