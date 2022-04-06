//
//  Screen+CoreDataProperties.swift
//  App
//
//  Created by Anthony Tranduc on 4/5/22.
//
//

import Foundation
import CoreData


extension Screen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Screen> {
        return NSFetchRequest<Screen>(entityName: "Screen")
    }

    @NSManaged public var instructions: String?
    @NSManaged public var type: Int64
    @NSManaged public var media: Media?

}

extension Screen : Identifiable {

}
