//
//  FriendsViewController.swift
//  Run
//
//  Created by Steven Li on 12/3/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class FriendsViewController: UIViewController, UITableViewDelegate  {
  
    @IBAction func UserInfoSegue(sender: AnyObject) {
        var friendUserId = userIdArray[sender.tag]
        mainInstance.friendId = friendUserId
    }
    @IBOutlet weak var FriendsTableView: UITableView!
    var friendString:String?
    var friendArray: [String] = []

    var userIdArray: [Int] = []
    var userNameArray: [String] = []
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userNameArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FriendInfoCell {
        let identifier:String = "FriendInfoCell"
        let cell:FriendInfoCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendInfoCell
        
            cell.NameLabel?.text = self.userNameArray[indexPath.row]
            print(cell.NameLabel?.text)
        cell.InfoButton.tag = indexPath.row
//        cell.InfoButton.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let currentId = userIdArray[indexPath.row]
       
        return cell
    }
    func loadFriends() {
        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        
        friendString = currentUser.friends
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
    func clearArrays() {
         friendString?.removeAll()
         friendArray.removeAll()
         userIdArray.removeAll()
         userNameArray.removeAll()
    }

    override func viewDidAppear(animated: Bool) {
        print("friendappear")
        print("\(userNameArray)")
        clearArrays()
        loadFriends()
        self.FriendsTableView.reloadData()

    }
    override func viewDidLoad() {
        FriendsTableView.delegate = self
        clearArrays()
        loadFriends()
   
        
    }
}
class FriendInfoCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var InfoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}