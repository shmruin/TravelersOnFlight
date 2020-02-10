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
    
    static func makeUid() -> String {
        return UUID().uuidString
    }
}

extension ScheduleItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

class DayScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Day.rawValue
    @objc dynamic var day: Int = 1
    @objc dynamic var date: Date = Date()
}

class SpecificScheduleItem: ScheduleItem {
    @objc dynamic var level: Int = ScheduleLevel.Specific.rawValue
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var area: String = ""
    @objc dynamic var placeCategory: String = ""
    @objc dynamic var placeName: String = ""
    @objc dynamic var activityCategory: String = ""
    @objc dynamic var activityName: String = ""
    @objc dynamic var stTime: Date = Date()
    @objc dynamic var fnTime: Date = Date()
}
