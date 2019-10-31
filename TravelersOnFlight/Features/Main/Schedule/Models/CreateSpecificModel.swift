//
//  CreateSpecificModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 01/11/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class SpecificDataModel {
    var itemUid: String
    var countries: BehaviorRelay<String>?
    var cities: BehaviorRelay<String>?
    var stTime: BehaviorRelay<Date>?
    var fnTime: BehaviorRelay<Date>?
    
    init(itemUid: String, countries: BehaviorRelay<String>, cities: BehaviorRelay<String>,
         stTime: BehaviorRelay<Date>, fnTime: BehaviorRelay<Date>) {
        self.itemUid = itemUid
        self.countries = countries
        self.cities = cities
        self.stTime = stTime
        self.fnTime = fnTime
    }
}

extension SpecificDataModel: IdentifiableType {
    var identity: String {
        return itemUid
    }
}

extension SpecificDataModel: Equatable {
    static func == (lhs: SpecificDataModel, rhs: SpecificDataModel) -> Bool {
        return lhs.itemUid == rhs.itemUid
    }
}

// Use for 'new' section
let DummySpecificData = SpecificDataModel(itemUid: TravelItem.makeUid(),
                                          countries: BehaviorRelay<String>(value: ""),
                                          cities: BehaviorRelay<String>(value: ""),
                                          stTime: BehaviorRelay<Date>(value: Date()),
                                          fnTime: BehaviorRelay<Date>(value: Date()))
