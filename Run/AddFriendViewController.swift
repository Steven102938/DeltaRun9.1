//
//  AddFriendViewController.swift
//  Run
//
//  Created by Steven Li on 12/3/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddFriendViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate {
  
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var UserTableView: UITableView!

    var searchActive : Bool = false
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var filtered:[String] = []
    var userIdArray: [Int] = []
    var userNameArray: [String] = []
    var friendString:String?
    var userId:NSNumber?
    var verificationId:String?
    var userName:String?
    var displayName:String?
    var userPassword:String?
    var friendArray: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /* Setup delegates */
        UserTableView.delegate = self
        SearchBar.delegate = self
     
        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
         var currentUser = userInfoData.removeLast()
         friendString = currentUser.friends
         userId = currentUser.userid!
         verificationId = currentUser.verificationid
         userName = currentUser.name
         displayName = currentUser.username
         userPassword = currentUser.password
         friendArray = friendString!.characters.split{$0 == " "}.map(String.init)


        
    }
  
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func loadFriends() {
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()

        friendString = currentUser.friends
        friendArray = friendString!.characters.split{$0 == " "}.map(String.init)

    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.userIdArray.removeAll()
        self.userNameArray.removeAll()
            if searchText.characters.count <= 3 {
            }
            else{
                
            var runQuery:String = "http://jeber.me/userquery.php?namequery=" + "\(searchText)"
            var directionsURLString = NSURL(string: runQuery)
                if directionsURLString != nil {
            let data = NSData(contentsOfURL: directionsURLString!)
            let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
            print(dictionary)
            for user in dictionary{
                let tempUserName = user["username"]! as! String
                let tempUserId = user["userid"]!!.integerValue

                self.userIdArray.append(tempUserId)
                self.userNameArray.append(tempUserName)
                        }
                }
                else{
                    
                }
        }
            
        
        if(userIdArray.count == 0){
            searchActive = false
        } else {
            searchActive = true
        }
        self.UserTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return userNameArray.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FriendCell {
        let identifier:String = "FriendCell"
        let cell:FriendCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendCell
        if(searchActive){
            cell.NameLabel?.text = self.userNameArray[indexPath.row]
            print(cell.NameLabel?.text)
            print("newcell")
        }
        
        
        let currentId = userIdArray[indexPath.row]
        if friendArray.contains("\(currentId)") {
        cell.AddFriendButton.hidden = true
        cell.RemoveFriendButton.hidden = false
        }
        else{
        cell.AddFriendButton.hidden = false
        cell.RemoveFriendButton.hidden = true
        }
         cell.AddFriendButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
         cell.RemoveFriendButton.addTarget(self, action: "removeFriend:", forControlEvents: .TouchUpInside)
        return cell
    }
    func addFriend(sender: UIButton!) {
        
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! FriendCell
        let indexPath = UserTableView.indexPathForCell(cell)
        let row = indexPath?.row
        
        
        var addedFriend = userIdArray[row!]
        print(addedFriend)
        var newAddedString = friendString! + "\(addedFriend)" + " "
        var newAddedWebString = newAddedString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)

        let urlPath: String = "http://jeber.me/changefriend.php?friendstring=" + "\(newAddedWebString)" + "&userid=" + "\(userId!)" + "&verificationid=" + "\(verificationId!)"
        print(urlPath)
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
        let loginUser = NSEntityDescription.entityForName("User",
            inManagedObjectContext: managedObjectContext!)
        let loginInfo = User(entity: loginUser!, insertIntoManagedObjectContext: managedObjectContext)
        loginInfo.userid = userId
        loginInfo.name = userName
        loginInfo.username = displayName
        loginInfo.password = userPassword
        loginInfo.verificationid = verificationId
        loginInfo.friends = newAddedString
        
        var error: NSError?
        
        do {
            try managedObjectContext!.save()
            
        } catch  {
            let nserror = error as! NSError
            abort()
        }
        
        friendString = newAddedString
        loadFriends()
        print(friendArray)
        cell.AddFriendButton.hidden = true
        cell.RemoveFriendButton.hidden = false
        print("yourButton was pressed")
    }
    func removeFriend(sender: UIButton!){
        let button = sender as UIButton
        let view = button.superview!
        let cell = view.superview as! FriendCell
        let indexPath = UserTableView.indexPathForCell(cell)
        let row = indexPath?.row
        
        var newRemovedString:String = ""
        print(friendArray)
        var friendToRemove = userIdArray[row!]
        print("friend to remove" + "\(friendToRemove)")
        var removedFriend = friendArray.filter{$0 != "\(friendToRemove)"}
        print(removedFriend)
        if removedFriend.count == 1 {
        newRemovedString = removedFriend.joinWithSeparator("")  + " "
        }
        else{
        newRemovedString = removedFriend.joinWithSeparator(" ")
        }
        var newRemovedWebString = newRemovedString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let urlPath: String = "http://jeber.me/changefriend.php?friendstring=" + "\(newRemovedWebString)" + "&userid=" + "\(userId!)" + "&verificationid=" + "\(verificationId!)"
        print(urlPath)
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
        
        let loginUser = NSEntityDescription.entityForName("User",
            inManagedObjectContext: managedObjectContext!)
        let loginInfo = User(entity: loginUser!, insertIntoManagedObjectContext: managedObjectContext)
        loginInfo.userid = userId
        loginInfo.name = userName
        loginInfo.username = displayName
        loginInfo.password = userPassword
        loginInfo.verificationid = verificationId
        loginInfo.friends = newRemovedString
        
        var error: NSError?
        
        do {
            try managedObjectContext!.save()
            
        } catch  {
            let nserror = error as! NSError
            abort()
        }
        
        friendString = newRemovedString
        loadFriends()
        cell.AddFriendButton.hidden = false
        cell.RemoveFriendButton.hidden = true

    }
}

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var AddFriendButton: UIButton!
    @IBOutlet weak var RemoveFriendButton: UIButton!
    @IBOutlet weak var NameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}