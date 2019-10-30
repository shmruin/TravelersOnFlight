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

class ScheduleItem: Object, Relationable {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension ScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class TravelScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Travel.rawValue
}

class DayScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Day.rawValue
    @objc dynamic var day: Date = Date()
}

//class LocationScheduleItem: Object, ScheduleItem {
//    @objc dynamic var uid: String = UUID().uuidString
//    @objc dynamic var parentUid: String = ""
//    @objc dynamic var level: Int = ScheduleLevel.Location.rawValue
//    @objc dynamic var country: String = ""
//    @objc dynamic var city: String = ""
//
//    override class func primaryKey() -> String? {
//        return "uid"
//    }
//}
//
//extension LocationScheduleItem: IdentifiableType {
//    var identity: String {
//        return self.isInvalidated ? "" : uid
//    }
//}

class SpecificScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var time: Date = Date()
}

class PlaceScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var placeCategory: String = ""
    @objc dynamic var placeName: String = ""
}

class ActivityScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var activityCategory: String = ""
    @objc dynamic var activityName: String = ""
}
