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

class TravelRoot: Object, Relationable {
    static let TravelRootInstance = TravelRoot()
    
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = "-1"
}

class TravelItem: Object, Relationable {
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var parentUid: String = "0"
    @objc dynamic var firstCity: String = "NoWhere"
    @objc dynamic var numCountries: Int = 0
    @objc dynamic var numCities: Int = 0
    @objc dynamic var stDate: Date = Date()
    @objc dynamic var fnDate: Date = Date()
    @objc dynamic var theme: String = TravelTheme.AlwaysGood.rawValue
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension TravelItem: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : uid
    }
}

let DummyTravelItem = TravelItem()
