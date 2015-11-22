//
//  UserLoginViewController.swift
//  Run
//
//  Created by Steven Li on 10/24/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import GoogleMaps
class UserLoginViewController:UIViewController {
    
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var WrongUsernameLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
   
    var keyboardInt:Int?
    var Baseurl = Firebase(url: "https://blazing-torch-6156.firebaseio.com")
    var userid:Int?
    var username:String?
    var email:String?
    var returnBool:Bool?
    var managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    //Optional(<5b6e756c 6c5d>)
    @IBAction func Signup(sender: AnyObject) {
        resignFirstResponder()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @IBAction func Login(sender: AnyObject) {
        var usernameInput = UsernameField.text
        var password = PasswordField.text
   
        var urlPath: String = "http://192.168.1.137/login.php?name=" + "\(usernameInput!)" + "&password=" + "\(password!)"
        print(urlPath)
        if urlPath.rangeOfString(" ") == nil{
        var url: NSURL = NSURL(string: urlPath)!
        let data = NSData(contentsOfURL: url)
            print(data)
            if data != nil {
        var dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray

        print(dictionary)
        for data in dictionary{
            if let useridLoop = data["userid"] {
            let verificationid = data["verificationid"]!
            let useridTemp = useridLoop as! String
            print(useridTemp)
            var useridTemp2:Int = Int("\(useridTemp)")!
            var useridFetch:NSNumber = NSNumber(integer: useridTemp2)
            var verificationIdFetch:String = "\(verificationid!)"
                
            let loginUser = NSEntityDescription.entityForName("User",
                inManagedObjectContext: managedObjectContext)
            let loginInfo = User(entity: loginUser!, insertIntoManagedObjectContext: managedObjectContext)
            loginInfo.userid = useridFetch
            loginInfo.username = usernameInput
            loginInfo.password = password
            loginInfo.verificationid = verificationIdFetch
                print(verificationIdFetch)
            var error: NSError?
            
            do {
                try managedObjectContext.save()
            } catch  {
                let nserror = error as NSError
                abort()
            }
                FindRoutes()
                let SegueName = "LoginSegue"
                self.performSegueWithIdentifier(SegueName, sender: nil)

        }
            else{
                WrongUsernameLabel.hidden = false
            }
    }
        
        //Fetching data with user id
                //        print(usernameInput)
                //        Baseurl.authUser("\(usernameInput!)", password:"\(password!)") {
                //            error, authData in
                //            if error != nil {
                //                print("error")
                //                if let errorCode = FAuthenticationError(rawValue: error.code) {
                //                    switch (errorCode) {
                //                    case .UserDoesNotExist:
                //                        print("Handle invalid user")
                //                    case .InvalidEmail:
                //                        print("Handle invalid email")
                //                    case .InvalidPassword:
                //                        print("Handle invalid password")
                //                    default:
                //                        print("Handle default situation")
                //                    }
                //                }
                //                // Something went wrong. :(
                //            } else {
                //                // Authentication just completed successfully :)
                //                // The logged in user's unique identifier
                //               
                //                print("append")
                //                print(authData.uid)
                //                print(authData.providerData)
                //                let SegueName = "LoginSegue"
                //                self.performSegueWithIdentifier(SegueName, sender: nil)
                //            }
                //        }

        //segue into app
      
            }
        }
    }
    
    func FindRoutes() {
        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        var loginUserId = currentUser.userid
        var verificationIdTemp:String = currentUser.verificationid!
        var verificationIdTemp2:String = verificationIdTemp.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var verificationId:String = verificationIdTemp2.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        print(verificationId)
        var runQuery:String = "http://192.168.1.137/runquery.php?userid=" + "\(loginUserId!)" + "&verificationid=" + "\(verificationId)"
        var directionsURLString = NSURL(string: runQuery)
        print(directionsURLString!)
        let data = NSData(contentsOfURL: directionsURLString!)
        let dictionary: NSMutableArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableArray
     //   print(dictionary)
        clearRoutes()
        for user in dictionary{
            let tempName = user["name"]! as! String
            let tempDuration = user["duration"]!!.integerValue
            let tempDistance = user["distance"]!!.doubleValue
            let tempDaterun = user["daterun"]! as! String
            let tempCoordinates = user["coordinates"]! as! String
            let tempRunId = user["runid"]! as! String
            
            let savedRun = NSEntityDescription.entityForName("RunInfo",
                inManagedObjectContext: managedObjectContext)
            let runInfo = RunInfo(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
            runInfo.distance = tempDistance
            runInfo.duration = tempDuration
            runInfo.timestamp = tempDaterun
            runInfo.name = tempName
            runInfo.generated = false
            runInfo.polyline = tempCoordinates
            var error: NSError?
            let request = NSFetchRequest(entityName: "RunInfo")
            
            do {
                try managedObjectContext.save()
            } catch var error1 as NSError {
                error = error1
            }
        }
        
      
        // 2
        
  //      for location in locations {
  //         let savedRun = NSEntityDescription.entityForName("Location",
  //              inManagedObjectContext: managedObjectContext)
  //          let savedlocation = Location(entity: savedRun!, insertIntoManagedObjectContext: managedObjectContext)
            
  //          savedlocation.timestamp = location.timestamp
  //           savedlocation.latitude = location.coordinate.latitude
  //            savedlocation.longitude = location.coordinate.longitude
//            runInfo.mutableOrderedSetValueForKey("locations").addObject(savedlocation)
            
    //    }
        
        // 3
       
    }
    func clearRoutes(){
        print("clearing")
    let request = NSFetchRequest(entityName: "RunInfo")
    var RunInfoData = (try! managedObjectContext.executeFetchRequest(request)) as! [RunInfo]
        print(RunInfoData.count)
        while RunInfoData.count != 0 {
        var count:Int = RunInfoData.count
        print("bounds")
        self.managedObjectContext.deleteObject(RunInfoData.removeLast() as NSManagedObject)
            print(RunInfoData.count)
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
        }
    print("cleared")
    }
    func keyboardWillShow(notification:NSNotification){
        let sender: [NSObject:AnyObject] = notification.userInfo!
      
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if keyboardInt == 0 || keyboardInt == nil {
            if returnBool != true {

                UIView.animateWithDuration(0.1, animations: {() -> Void in
                    print(self.LoginView.frame.origin.y)
                    print(keyboardSize.height)
                    self.bottomConstraint.constant += keyboardSize.height
                    self.LoginView.frame.origin.y -= keyboardSize.height
                    print(self.LoginView.frame.origin.y)
                    self.keyboardInt = 1
                })
            }
        }
      
    }
    func keyboardWillHide(notification:NSNotification){
        let sender: [NSObject:AnyObject] = notification.userInfo!
      if self.keyboardInt == 1 {
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if returnBool != true {
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                print(self.LoginView.frame.origin.y)
                print(keyboardSize.height)
                self.bottomConstraint.constant -= keyboardSize.height
                self.LoginView.frame.origin.y += keyboardSize.height
                print(self.LoginView.frame.origin.y)
                self.keyboardInt = 0

            })
        }
      }
        else {
            print("d")
        }
    }
    func textFieldShouldReturn(TextField: UITextField) -> Bool{
        if TextField == UsernameField{
            returnBool = true

            UsernameField.resignFirstResponder()
            PasswordField.becomeFirstResponder()
        }
        else if TextField == PasswordField{
            returnBool = false
            PasswordField.resignFirstResponder()
            Login("#DANK")
        }
        return true
    }
  
    override func viewDidLoad() {
    
    WrongUsernameLabel.hidden = true
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        PasswordField.returnKeyType = UIReturnKeyType.Done
        self.UsernameField.delegate = self
        self.PasswordField.delegate = self
        
        
    }
    
}