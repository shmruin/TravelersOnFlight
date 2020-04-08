//
//  TravelItem.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxDataSources

@objc protocol Relationable {
    @objc dynamic var uid: String { get set }
    @objc dynamic var parentUid: String { get set }
}

class TravelItem: Object, Relationable {
    @objc dynamic var uid: String = ""
    @objc dynamic var parentUid: String = RootParentUid
    let countries = List<String>()
    let cities = List<String>()
    @objc dynamic var stDate: Date = Date()
    @objc dynamic var fnDate: Date = Date()
    @objc dynamic var theme: String = TravelTheme.getDefault().rawValue
    let dayItems = List<DayScheduleItem>()
    
    override static func primaryKey() -> String? {
        return "uid"
    }
}

extension TravelItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

let RootParentUid = UUID().uuidString
