//
//  UserSignUpViewController.swift
//  Run
//
//  Created by Steven Li on 11/8/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//

import Foundation
import UIKit

class UserSignUpViewController: UIViewController, UITextFieldDelegate {
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
    func textFieldShouldReturn(TextField: UITextField) -> Bool{
        if TextField == FirstNameTextField{
            returnBool = true
            
            FirstNameTextField.resignFirstResponder()
            LastNameTextField.becomeFirstResponder()
        }
        else if TextField == LastNameTextField{
            returnBool = false
            LastNameTextField.resignFirstResponder()
            EmailTextField.becomeFirstResponder()
        }
        else if TextField == EmailTextField{
            returnBool = false
            
            EmailTextField.resignFirstResponder()
            UsernameTextField.becomeFirstResponder()
        }
        else if TextField == UsernameTextField{
            UsernameTextField.resignFirstResponder()
            PasswordTextField.becomeFirstResponder()
        }
        return true
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
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
    }

  
}