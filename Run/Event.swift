//
//  Event.swift
//  Run
//
//  Created by Joshua Eberhardt on 3/26/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
import UIKit



struct Event {
    var name: String?
    var time: NSDate?
    var timeString: String?
    
    init(name: String?, time: NSDate?) {
        self.time = time
        self.name = name
        self.timeString = dateString(time!)
    }
}

func dateString(dateTime: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    
    let strDate = dateFormatter.stringFromDate(dateTime)
    return strDate
}