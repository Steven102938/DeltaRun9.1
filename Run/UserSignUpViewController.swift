//
//  UserSignUpViewController.swift
//  Run
//
//  Created by Steven Li on 11/8/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit

class UserSignUpViewController: UIViewController {
    var returnBool:Bool?

    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var SignUpView: UIView!
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
            let password = PasswordTextField.text
            let email = EmailTextField.text
            let firstname = FirstNameTextField.text
            let lastname = LastNameTextField.text
            let birthdate = dateTextField.text
            print(birthdate)
            let urlPath: String = "http://192.168.1.111/registeruser.php?name=" + "\(username!)" + "&password=" + "\(password!)" + "&email=" + "\(email!)" + "&firstname=" + "\(firstname!)" + "&lastname=" + "\(lastname!)" + "&birthdate=" + "\(birthdate!)"
            print(urlPath)
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            connection.start()
        }

    }
    
    func textFieldShouldReturn(TextField: UITextField) -> Bool{
        if TextField == FirstNameTextField{
            returnBool = true
            
            FirstNameTextField.resignFirstResponder()
            LastNameTextField.becomeFirstResponder()
        }
        else if TextField == LastNameTextField{
            returnBool = true
            LastNameTextField.resignFirstResponder()
            EmailTextField.becomeFirstResponder()
        }
        else if TextField == EmailTextField{
            returnBool = true
            
            EmailTextField.resignFirstResponder()
            UsernameTextField.becomeFirstResponder()
        }
        else if TextField == UsernameTextField{
            returnBool = true

            UsernameTextField.resignFirstResponder()
            PasswordTextField.becomeFirstResponder()
        }
        else if TextField == PasswordTextField{
            returnBool = true

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
    var keyboardInt:Int?
    func keyboardWillShow(notification:NSNotification){
        let sender: [NSObject:AnyObject] = notification.userInfo!
        
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if keyboardInt == 0 || keyboardInt == nil {
            if returnBool != true {
                
                UIView.animateWithDuration(0.1, animations: {() -> Void in
                    print(self.SignUpView.frame.origin.y)
                    print(keyboardSize.height)
                    self.bottomConstraint.constant += keyboardSize.height
                    self.SignUpView.frame.origin.y -= keyboardSize.height
                    print(self.SignUpView.frame.origin.y)
                    self.keyboardInt = 1
                })
            }
        }
        
    }
    func keyboardWillHide(notification:NSNotification){
        let sender: [NSObject:AnyObject] = notification.userInfo!
        
        let keyboardSize:CGSize = sender[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if returnBool != true {
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                print(self.SignUpView.frame.origin.y)
                print(keyboardSize.height)
                self.bottomConstraint.constant -= keyboardSize.height
                self.SignUpView.frame.origin.y += keyboardSize.height
                print(self.SignUpView.frame.origin.y)
                self.keyboardInt = 0
                
            })
        }
        else {
            print("d")
        }
    }
  
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
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