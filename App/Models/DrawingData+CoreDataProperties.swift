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
    @NSManaged public var pointTimes: NSObject?
    @NSManaged public var trialDate: String?
    @NSManaged public var partCond: String?
    @NSManaged public var screenNames: NSObject?
}

extension DrawingData : Identifiable {

}
