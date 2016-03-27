//
//  SampleEvents.swift
//  Run
//
//  Created by Joshua Eberhardt on 3/26/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//

import Foundation
//Set up sample data

let eventData = [
    Event(name:"Mile run", time: NSDate()),
    Event(name: "Marathon practice", time: stringToDate("03-26-16 7:00 am")),
    Event(name: "Buddy run", time: stringToDate("03-27-16 5:30 pm")) ]

func stringToDate(str: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM-dd-yy hh:mm a"
    let date = dateFormatter.dateFromString(str)
    return date!
}