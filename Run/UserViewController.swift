//
//  UserViewController.swift
//  Run
//
//  Created by Steven Li on 10/19/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserViewController: UIViewController{
    
    @IBOutlet weak var NameField: UILabel!
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var MilesRunLabel: UILabel!
    @IBOutlet weak var FriendButton: UIButton!
    @IBOutlet weak var FriendsLabel: UILabel!
    @IBOutlet weak var CaloriesBurntLabel: UILabel!
    
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

    override func viewDidLoad() {
        loadUserData()
        loadRunData()
          }
    
    func loadUserData() {
        var error: NSError?
        let request = NSFetchRequest(entityName: "User")
        var userData = (try! managedObjectContext?.executeFetchRequest(request)) as! [User]
        var currentUser = userData.removeLast()
        
        var friendString = currentUser.friends
        var friendArray = friendString.characters.split{$0 == " "}.map(String.init)
        FriendsLabel.text = "\(friendArray.count)"
        NameField.text = currentUser.name
        
        }
    func loadRunData() {
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        var runData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        var totalMilesRun:Double = 0.0
        print(runData)
            for run in runData{
            totalMilesRun += run.distance.doubleValue
                
            }
        MilesRunLabel.text = "\(totalMilesRun)"
        var caloriesBurnt = totalMilesRun * 100
        CaloriesBurntLabel.text = "\(caloriesBurnt)"
    }
    
    
}
