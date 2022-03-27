//
//  Screen+CoreDataProperties.swift
//  App
//
//  Created by Anthony Tranduc on 3/10/22.
//
//

import Foundation
import CoreData


extension Screen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Screen> {
        return NSFetchRequest<Screen>(entityName: "Screen")
    }

    @NSManaged public var type: Int64
    @NSManaged public var instructions: String?
    @NSManaged public var media: Data?

}

extension Screen : Identifiable {

}
