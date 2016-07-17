//
//  RunRequestViewController.swift
//  Run
//
//  Created by Steven Li on 3/29/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//
import Social
import Foundation
import UIKit
import CoreData
class RunRequestViewController:UIViewController {
  
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    @IBOutlet weak var chooseRunButton: UIButton!
    @IBOutlet weak var requestNameField: UITextField!
    @IBOutlet weak var requestMessageTextView: UITextView!
    @IBOutlet weak var dateRunTextField: UITextField!
    @IBOutlet weak var timeRunTextField: UITextField!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    
    @IBAction func FacebookPostButton(sender: AnyObject) {
        let userRequest = NSFetchRequest(entityName: "RunInfo")
        var runInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [RunInfo]
        var imageForPost:UIImage?
        var dateForRun:String?
        var timeForRun:String?
        for runInfo in runInfoData {
            var selectedRunId = mainInstance.routeNumber
            if runInfo.runid == selectedRunId {
                var decodedImage = runInfo.image
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                decodedImage = decodedImage.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                print(decodedImage)
                let decodedData = NSData(base64EncodedString: decodedImage, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                imageForPost = UIImage(data: decodedData!)
            }
            else {
            }
        }
        var selectedRun = runInfoData.removeLast()
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Come join me on a run on" + "\(dateRunTextField.text!)" + "at" + "\(timeRunTextField.text!)" + "on DeltaRun")
            facebookSheet.addImage(imageForPost)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    @IBAction func sendButton(sender: AnyObject) {
        var routeId = mainInstance.routeNumber
        var routeString = mainInstance.globalString
     //   var dateForRequest = dateRunPicker.date
        
        var dateString = dateRunTextField.text
        var recipientArray:[Int] = mainInstance.globalArray
        var recipientString = recipientArray.map(String.init).joinWithSeparator("%20")
        
        let userRequest = NSFetchRequest(entityName: "User")
        var userInfoData = (try! managedObjectContext!.executeFetchRequest(userRequest)) as! [User]
        var currentUser = userInfoData.removeLast()
        
        var username:String = currentUser.username!
        var userid:Int = currentUser.userid! as Int
        var verificationid:String = currentUser.verificationid!
        var requestMessage:String = requestMessageTextView.text
        var requestName:String = requestNameField.text!
        
        var webRequestMessageString = requestMessage.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        
        let urlPost = NSURL(string: "http://jeber.me/sendrequest.php");
        let requestPost = NSMutableURLRequest(URL:urlPost!)
        requestPost.HTTPMethod = "POST";
        
        let postString = "requestname=" + "\(requestName)" + "&requestmessage=" + "\(webRequestMessageString)" + "&requestrouteid=" + "\(routeId!)" + "&username=" + "\(username)" + "&userid=" + "\(userid)" + "&daterequest=" + "\(dateString!)" + "&recipientid=" + "\(recipientString)" + "&userverificationid=" + "\(verificationid)";
        requestPost.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithRequest(requestPost, completionHandler: {data, response, error -> Void in
            
            let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
            print("Data: \(urlContent)");
        });
        
        task.resume();

        
        
        
//        var urlPath: String = "http://jeber.me/sendrequest.php?requestname=" + "\(requestName)" + "&requestmessage=" + "\(webRequestMessageString)" + "&requestrouteid=" + "\(routeId!)" + "&username=" + "\(username)" + "&userid=" + "\(userid)" + "&daterequest=" + "\(dateString!)" + "&recipientid=" + "\(recipientString)" + "&userverificationid=" + "\(verificationid)"
//        print(urlPath)
//        var url = NSURL(string: urlPath)
//        print(url)
//        var request: NSURLRequest = NSURLRequest(URL: url!)
//        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
//        connection.start()
    }
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        
        var datePickerView  : UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("dateTextFieldDidChange:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func timeTextFieldEditing(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Time
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("timeTextFieldDidChange:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    func dateTextFieldDidChange(sender:UIDatePicker) {
        print("valueCHanged")
            
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateRunTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    func timeTextFieldDidChange(sender:UIDatePicker) {
        print("valueCHanged")
        
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "HH:mm a"
        
        timeRunTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    override func viewDidLoad() {

        sendButtonOutlet.layer.borderColor = UIColor.grayColor().CGColor
        
    }
    override func viewDidAppear(animated: Bool) {
        print("appear")
        print(mainInstance.globalArray)
        var selectedRouteName = mainInstance.globalString
        if selectedRouteName! != "Error"{
            chooseRunButton.setTitle(selectedRouteName, forState: .Normal)
        }
    }
    
}