//
//  NearbyRuns+CoreDataProperties.swift
//  Run
//
//  Created by Steven Li on 12/22/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NearbyRuns {

    @NSManaged var nearbydistance: NSNumber?
    @NSManaged var nearbyduration: NSNumber?
    @NSManaged var nearbyrunby: String?
    @NSManaged var nearbyimage: String?
    @NSManaged var nearbyname: String?
    @NSManaged var nearbypolyline: String?
    @NSManaged var nearbyrunid: NSNumber?
    @NSManaged var nearbytimestamp: String?

}
