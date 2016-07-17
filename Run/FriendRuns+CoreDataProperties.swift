//
//  FriendRuns+CoreDataProperties.swift
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

extension FriendRuns {
    
    @NSManaged var friendrunby: String?
    @NSManaged var frienddistance: NSNumber?
    @NSManaged var friendduration: NSNumber?
    @NSManaged var friendimage: String?
    @NSManaged var friendname: String?
    @NSManaged var friendpolyline: String?
    @NSManaged var friendrunid: NSNumber?
    @NSManaged var friendtimestamp: String?

}
