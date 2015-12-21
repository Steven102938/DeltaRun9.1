//
//  SignUpViewController.swift
//  Run
//
//  Created by Steven Li on 11/15/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    var returnBoolSign:Bool?
    var Baseurl = Firebase(url: "https://blazing-torch-6156.firebaseio.com")
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var SignUpView: UIView!
    @IBOutlet weak var signUpBottomConstraint: NSLayoutConstraint!
    
    @IBAction func dateEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    @IBAction func SignUpPressed(sender: AnyObject) {
        
        if UsernameTextField.text == "" || PasswordTextField.text == "" || EmailTextField.text == "" || FirstNameTextField.text == "" || LastNameTextField.text == "" || dateTextField == "" {
        }
        else {
            let username = UsernameTextField.text
            let email = EmailTextField.text
            let password = PasswordTextField.text
            let firstname = FirstNameTextField.text
            let lastname = LastNameTextField.text
            let birthdate = dateTextField.text

//            Baseurl.createUser("\(email!)", password: "\(password!)",
//                withValueCompletionBlock: { error, result in
//                    if error != nil {
//                        print("error")
//                        // There was an error creating the account
//                    } else {
//                        print(result)
//                        let uid = result["uid"] as? String
//                        print("Successfully created user account with uid: \(uid)")
//                    }
//            })
//            
//            Baseurl.authUser("\(email!)", password: "\(password!)") {
//                error, authData in
//                if error != nil {
//                    // an error occured while attempting login
//                } else {
//                    // Authentication just completed successfully :)
//                    // The logged in user's unique identifier
//                    print(authData.uid)
//                    // Create a new user dictionary accessing the user's info
//                    // provided by the authData parameter
//                    let newUser = [
//                        "provider": authData.provider,
//                        "displayName": "\(username)",
//                        "firstName": "\(firstname)",
//                        "lastName": "\(lastname)",
//                        "birthDate": "\(birthdate)"
//                    ]
//                    
//                    // Create a child path with a key set to the uid underneath the "users" node
//                    // This creates a URL path like the following:
//                    //                  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
//                    self.Baseurl.childByAppendingPath("users")
//                    print("append")
//                    print(authData.uid)
//                    print(authData.providerData)
//                    print("\(newUser)")
//                    self.Baseurl.childByAppendingPath(authData.uid).setValue(newUser)
//                    let SegueName = "LoginSegue"
//                    self.performSegueWithIdentifier(SegueName, sender: nil)
//                }
//            }
            
                        print(birthdate)
                        let urlPath: String = "http://192.168.1.133/registeruser.php?name=" + "\(username!)" + "&password=" + "\(password!)" + "&email=" + "\(email!)" + "&firstname=" + "\(firstname!)" + "&lastname=" + "\(lastname!)" + "&birthdate=" + "\(birthdate!)"
                        print(urlPath)
                        let url: NSURL = NSURL(string: urlPath)!
                        let request: NSURLRequest = NSURLRequest(URL: url)
                        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                        connection.start()
        }
        
    }
    
    func textFieldShouldReturn(TextField: UITextField) -> Bool{
        if TextField == FirstNameTextField{
            returnBoolSign = true
            
            FirstNameTextField.resignFirstResponder()
            LastNameTextField.becomeFirstResponder()
        }
        else if TextField == LastNameTextField{
            returnBoolSign = true
            LastNameTextField.resignFirstResponder()
            EmailTextField.becomeFirstResponder()
        }
        else if TextField == EmailTextField{
            returnBoolSign = true
            
            EmailTextField.resignFirstResponder()
            UsernameTextField.becomeFirstResponder()
        }
        else if TextField == UsernameTextField{
            returnBoolSign = true
            
            UsernameTextField.resignFirstResponder()
            PasswordTextField.becomeFirstResponder()
        }
        else if TextField == PasswordTextField{
            returnBoolSign = true
            
            PasswordTextField.resignFirstResponder()
            dateTextField.becomeFirstResponder()
        }
        else if TextField == dateTextField{
            dateTextField.resignFirstResponder()
            
        }
        return true
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
        //        let dateFormatter = NSDateFormatter()
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        //        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        //        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        //
        let urlDateFormatter = NSDateFormatter()
        urlDateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = urlDateFormatter.stringFromDate(sender.date)
    }
    var keyboardIntSign:Int?
    func signKeyboardWillShow(notification:NSNotification){
        var sender: [NSObject:AnyObject] = notification.userInfo!
        
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if keyboardIntSign == 0 || keyboardIntSign == nil {
            if returnBoolSign != true {
                
                UIView.animateWithDuration(0.1, animations: {() -> Void in
                    print("\(self.SignUpView.frame.origin.y)" + "sign")
                    print(keyboardSize.height)
                    self.signUpBottomConstraint.constant += keyboardSize.height
                    self.SignUpView.frame.origin.y -= keyboardSize.height
                    print(self.SignUpView.frame.origin.y)
                    self.keyboardIntSign = 1
                })
            }
        }
        
    }
    func signKeyboardWillHide(notification:NSNotification){
        var sender: [NSObject:AnyObject] = notification.userInfo!
        if self.keyboardIntSign == 1 {
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if returnBoolSign != true {
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                print("\(self.SignUpView.frame.origin.y)" + "sign down")
                print(keyboardSize.height)
                self.signUpBottomConstraint.constant -= keyboardSize.height
                self.SignUpView.frame.origin.y += keyboardSize.height
                print(self.SignUpView.frame.origin.y)
                self.keyboardIntSign = 0
                
            })
        }
        }
        else {
            print("d")
        }
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("signKeyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("signKeyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        self.FirstNameTextField.delegate = self
        self.LastNameTextField.delegate = self
        self.EmailTextField.delegate = self
        self.UsernameTextField.delegate = self
        self.PasswordTextField.delegate = self
        self.dateTextField.delegate = self
        addToolBar(FirstNameTextField)
        addToolBar(LastNameTextField)
        addToolBar(EmailTextField)
        addToolBar(UsernameTextField)
        addToolBar(PasswordTextField)
        addToolBar(dateTextField)
        
        print("\(self.SignUpView.frame.origin.y)" + "init")
        
        
    }
    
    
}
extension UIViewController: UITextFieldDelegate{
    func addToolBar(textField: UITextField){
        var toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
        var leftPressed = UIBarButtonItem(title: "〈", style: UIBarButtonItemStyle.Plain, target: self, action: "leftPressed")
        var rightPressed = UIBarButtonItem(title: "〉", style: UIBarButtonItemStyle.Plain, target: self, action: "rightPressed")
        var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([leftPressed, rightPressed, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    func donePressed(){
        view.endEditing(true)
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
}