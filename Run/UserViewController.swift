//
//  UserViewController.swift
//  Run
//
//  Created by Steven Li on 10/19/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit
class UserViewController: UIViewController{
    var directionsURLString = NSURL(string: "http://192.168.1.111/database.php/")
    var users = [String:String]()
    
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var RecentRuns: UITableView!
    
    @IBAction func Register(sender: AnyObject) {
        if UsernameField.text == "" || PasswordField.text == "" || EmailField.text == "" {
        }
        else {
            let username = UsernameField.text
            let password = PasswordField.text
            let email = EmailField.text
          
            let urlPath: String = "http://192.168.1.111/registeruser.php?name=" + "\(username!)" + "&password=" + "\(password!)" + "&email=" + "\(email!)"
            print(urlPath)
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            connection.start()
        }
    }
    override func viewDidLoad() {
    
    let data = NSData(contentsOfURL: directionsURLString!)
        
    print("data")
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
        print("\(dictionary)")
        for user in dictionary{
            let usernameTemp = user["username"]
            let passwordTemp = user["password"]
            let username = String(usernameTemp as! NSString)
            let password = String(passwordTemp as! NSString)
            users[username] = password
            }
        }
    }
