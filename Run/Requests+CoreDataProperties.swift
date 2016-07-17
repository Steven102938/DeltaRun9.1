//
//  Requests+CoreDataProperties.swift
//  Run
//
//  Created by Steven Li on 5/9/16.
//  Copyright © 2016 Steven Li. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Requests {

    @NSManaged var requestfrom: String?
    @NSManaged var requestmessage: String?
    @NSManaged var requestname: String?
    @NSManaged var requestrundate: String?
    @NSManaged var requestimage: String?
    @NSManaged var requestrunid: NSNumber?
    @NSManaged var requestid: NSNumber?
    @NSManaged var requestfromid: NSNumber?

}
