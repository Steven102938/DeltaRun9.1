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
  
    @IBOutlet weak var FriendsTableView: UITableView!
    var friendString:String?
    var userIdArray: [Int] = []
    var userNameArray: [String] = []
    var friendArray: [String] = []
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userNameArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FriendInfoCell {
        let identifier:String = "FriendInfoCell"
        let cell:FriendInfoCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendInfoCell
        
            cell.NameLabel?.text = self.userNameArray[indexPath.row]
            print(cell.NameLabel?.text)
        
        let currentId = userIdArray[indexPath.row]
       
        return cell
    }

    
    override func viewDidLoad() {
        FriendsTableView.delegate = self

        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        
        friendString = currentUser.friends
        friendArray = friendString!.characters.split{$0 == " "}.map(String.init)
        var webFriendString = friendString!.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var userIdQuery:String = "http://abominable.science/useridquery.php?userid=" + "\(webFriendString)"
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