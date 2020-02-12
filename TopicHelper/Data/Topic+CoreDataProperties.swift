//
//  Topic+CoreDataProperties.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/8/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//
//

import Foundation
import CoreData

extension Topic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Topic> {
        return NSFetchRequest<Topic>(entityName: "Topic")
    }

    @NSManaged public var details: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isGem: Bool
    @NSManaged public var isUserTopic: Bool
    @NSManaged public var title: String?

}
