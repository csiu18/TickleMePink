//
//  DrawingData+CoreDataProperties.swift
//  App
//
//  Created by Sam Chan on 3/11/22.
//
//

import Foundation
import CoreData


extension DrawingData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrawingData> {
        return NSFetchRequest<DrawingData>(entityName: "DrawingData")
    }

    @NSManaged public var strokes: NSObject?
    @NSManaged public var identifier: String?
}

extension DrawingData : Identifiable {

}
