//
//  ScheduleItem.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxDataSources

enum ScheduleLevel: Int {
    case Travel = 0
    case Day
    case Location
    case Specific
    case Place
    case Activity
}

protocol ScheduleItem: Relationable {
}

class TravelScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Travel.rawValue
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension TravelScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class DayScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Day.rawValue
    @objc dynamic var day: Date = Date()
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension DayScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class LocationScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Location.rawValue
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension LocationScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class SpecificScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var time: Date = Date()
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension SpecificScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class PlaceScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var placeCategory: String = ""
    @objc dynamic var placeName: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension PlaceScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class ActivityScheduleItem: Object, ScheduleItem {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var activityCategory: String = ""
    @objc dynamic var activityName: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension ActivityScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}
