//
//  User+CoreDataProperties.swift
//  Run
//
//  Created by Steven Li on 10/28/15.
//  Copyright © 2015 Steven Li. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var password: String?
    @NSManaged var userid: Int64
    @NSManaged var username: String?

}
