//
//  CreateEvent.swift
//  Run
//
//  Created by Joshua Eberhardt on 3/25/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import EventKit
import UIKit

class CreateEvent: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func addButton(sender: UIButton) {
        //1
        let eventStore = EKEventStore()
        
        //2
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .Authorized:
            insertEvent(eventStore)
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            //3
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion:
                {[weak self] (granted: Bool, error: NSError?) -> Void in
                    if granted {
                        self!.insertEvent(eventStore)
                    } else {
                        print("Access denied")
                    }
                })
        default:
            print("Case Default")
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)

    }
    
    
    func insertEvent(store: EKEventStore) {
        
        //1
        let calendars = store.calendarsForEntityType(EKEntityType.Event)
        //as! [EKCalendar]
        
        var calendarFound: Bool
        calendarFound = false
        for calendar in calendars {
            //2
            if calendar.title == "DeltaRun" {
                calendarFound = true
                //3
                let startDate = datePicker.date
                //2 hours
                let endDate = startDate.dateByAddingTimeInterval(1 * 60 * 60)
                
                //4
                //Create Event
                let event = EKEvent(eventStore: store)
                event.calendar = calendar
                event.title = "Run"
                event.startDate = startDate
                event.endDate = endDate
                
                //5
                //Save Event in Calendar
                //var error: NSError?
                //let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
                //if result == false {
                //    if let theError = error {
                //        print("An error occured \(theError)")
                //    }
                //}
                
                var saveToCalendarError: NSError?
                let success: Bool
                do {
                    try store.saveEvent(event, span: .ThisEvent)
                    success = true
                } catch let error as NSError {
                    saveToCalendarError = error
                    success = false
                } catch {
                    fatalError()
                }
            }
        }
        if calendarFound == false {
            print("In order to use this feature, create a calendar named DeltaRun")
        }
    }
    
    
    
    func datePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        dateLabel.text = strDate
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

