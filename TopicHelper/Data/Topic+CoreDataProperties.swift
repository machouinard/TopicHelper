//
//  Topic+CoreDataProperties.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/3/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//
//

import Foundation
import CoreData


extension Topic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Topic> {
        return NSFetchRequest<Topic>(entityName: "Topic")
    }

    @NSManaged public var title: String?
    @NSManaged public var details: String?
    @NSManaged public var isFavorite: Bool

}
