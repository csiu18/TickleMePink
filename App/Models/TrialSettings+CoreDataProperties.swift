//
//  TrialSettings+CoreDataProperties.swift
//  App
//
//  Created by Anthony Tranduc on 3/10/22.
//
//

import Foundation
import CoreData


extension TrialSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrialSettings> {
        return NSFetchRequest<TrialSettings>(entityName: "TrialSettings")
    }

    @NSManaged public var strokeRed: Double
    @NSManaged public var strokeGreen: Double
    @NSManaged public var strokeBlue: Double
    @NSManaged public var partCondition: String?
    @NSManaged public var screenToTrialSettings: NSOrderedSet?

}

// MARK: Generated accessors for screenToTrialSettings
extension TrialSettings {

    @objc(insertObject:inScreenToTrialSettingsAtIndex:)
    @NSManaged public func insertIntoScreenToTrialSettings(_ value: Screen, at idx: Int)

    @objc(removeObjectFromScreenToTrialSettingsAtIndex:)
    @NSManaged public func removeFromScreenToTrialSettings(at idx: Int)

    @objc(insertScreenToTrialSettings:atIndexes:)
    @NSManaged public func insertIntoScreenToTrialSettings(_ values: [Screen], at indexes: NSIndexSet)

    @objc(removeScreenToTrialSettingsAtIndexes:)
    @NSManaged public func removeFromScreenToTrialSettings(at indexes: NSIndexSet)

    @objc(replaceObjectInScreenToTrialSettingsAtIndex:withObject:)
    @NSManaged public func replaceScreenToTrialSettings(at idx: Int, with value: Screen)

    @objc(replaceScreenToTrialSettingsAtIndexes:withScreenToTrialSettings:)
    @NSManaged public func replaceScreenToTrialSettings(at indexes: NSIndexSet, with values: [Screen])

    @objc(addScreenToTrialSettingsObject:)
    @NSManaged public func addToScreenToTrialSettings(_ value: Screen)

    @objc(removeScreenToTrialSettingsObject:)
    @NSManaged public func removeFromScreenToTrialSettings(_ value: Screen)

    @objc(addScreenToTrialSettings:)
    @NSManaged public func addToScreenToTrialSettings(_ values: NSOrderedSet)

    @objc(removeScreenToTrialSettings:)
    @NSManaged public func removeFromScreenToTrialSettings(_ values: NSOrderedSet)

}

extension TrialSettings : Identifiable {

}
