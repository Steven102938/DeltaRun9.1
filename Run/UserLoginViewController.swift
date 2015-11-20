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
   
        var urlPath: String = "http://192.168.1.137/login.php?name=" + "\(usernameInput!)" + "&password=" + "\(password!)"
        print(urlPath)
        if urlPath.rangeOfString(" ") == nil{
        var url: NSURL = NSURL(string: urlPath)!
        let data = NSData(contentsOfURL: url)
            print(data)
        
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
                let SegueName = "LoginSegue"
                self.performSegueWithIdentifier(SegueName, sender: nil)

        }
            else{
                WrongUsernameLabel.hidden = false
            }
    }
        
        //Fetching data with user id
        
        //segue into app
      
       
        }
    }
    var keyboardInt:Int?
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