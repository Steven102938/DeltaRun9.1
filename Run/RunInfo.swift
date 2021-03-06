//
//  RunInfo.swift
//  Run
//
//  Created by Steven Li on 10/8/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import Foundation
import CoreData

class RunInfo: NSManagedObject {

    @NSManaged var distance: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var image: String
    @NSManaged var name: String
    @NSManaged var timestamp: String
    @NSManaged var locations: NSOrderedSet
    @NSManaged var generated: Bool
    @NSManaged var polyline: String
    @NSManaged var runid: NSNumber

}
extension RunInfo {
    func addLocationObject(value:Location) {
        let items = self.mutableSetValueForKey("locations");
        items.addObject(value)
    }
    
    func removeLocationObject(value:Location) {
        let items = self.mutableSetValueForKey("locations");
        items.removeObject(value)
    }
}