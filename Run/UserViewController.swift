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
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var RecentRuns: UITableView!
    @IBOutlet weak var UserImage: UIImageView!
    
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

    override func viewDidLoad() {
        var error: NSError?
        let request = NSFetchRequest(entityName: "User")
        var userData = (try! managedObjectContext?.executeFetchRequest(request)) as! [User]
        var currentUser = userData.removeLast()
//        NameField.text = currentUser.
          }
    }
