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
    var areas: BehaviorRelay<String>?
    var stTime: BehaviorRelay<Date>?
    var fnTime: BehaviorRelay<Date>?
    var placeCategory: BehaviorRelay<PlaceCategoryRepository>?
    var placeName: BehaviorRelay<String>?
    var activityCategory: BehaviorRelay<ActivityCategoryRepository>?
    var activityName: BehaviorRelay<String>?
    
    init(itemUid: String, countries: BehaviorRelay<String>, cities: BehaviorRelay<String>, areas: BehaviorRelay<String>,
         stTime: BehaviorRelay<Date>, fnTime: BehaviorRelay<Date>, placeCategory: BehaviorRelay<PlaceCategoryRepository>, placeName: BehaviorRelay<String>, activityCategory: BehaviorRelay<ActivityCategoryRepository>, activityName: BehaviorRelay<String>) {
        self.itemUid = itemUid
        self.countries = countries
        self.cities = cities
        self.areas = areas
        self.stTime = stTime
        self.fnTime = fnTime
        self.placeCategory = placeCategory
        self.placeName = placeName
        self.activityCategory = activityCategory
        self.activityName = activityName
    }
    
    func timeDateFormatterHHmm() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }
    
    func makeStTime() -> String {
        let dateFormatter = timeDateFormatterHHmm()
        
        if let res = self.stTime?.value {
            return dateFormatter.string(from: res)
        } else {
            print("#ERROR - makeStTime something is nil")
            return "*stTime Error *"
        }
    }
    
    func makeFnTime() -> String {
        let dateFormatter = timeDateFormatterHHmm()
        
        if let res = self.fnTime?.value {
            return dateFormatter.string(from: res)
        } else {
            print("#ERROR - makeFnTime something is nil")
            return "*fnTime Error *"
        }
    }
    
    func makeAreaAndCity() -> String {
        if let area = areas?.value, let city = cities?.value {
            return area + ", " + city
        } else {
            print("#ERROR - makeAreaAndCity something is nil")
            return "*area and city Error *"
        }
    }
    
    func makePlaceCategory() -> String {
        if let pc = placeCategory?.value {
            return "@ " + pc.rawValue
        } else {
            print("#ERROR - makePlaceCategory something is nil")
            return "*placeCategory Error *"
        }
    }
    
    func makePlaceName() -> String {
        if let pn = placeName?.value {
            return pn
        } else {
            print("#ERROR - makePlaceName something is nil")
            return "*placeName Error *"
        }
    }
    
    func makeActivityCategory() -> String {
        if let ac = activityCategory?.value {
            return "# " + ac.rawValue
        } else {
            print("#ERROR - makeActivityCategory something is nil")
            return "*activityCategory Error *"
        }
    }
    
    func makeActivityName() -> String {
        if let an = activityName?.value {
            return an
        } else {
            print("#ERROR - makeActivityName something is nil")
            return "*activityName Error *"
        }
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
                                          areas: BehaviorRelay<String>(value: ""),
                                          stTime: BehaviorRelay<Date>(value: Date()),
                                          fnTime: BehaviorRelay<Date>(value: Date()),
                                          placeCategory: BehaviorRelay<PlaceCategoryRepository>(value: PlaceCategoryRepository.Airport),
                                          placeName: BehaviorRelay<String>(value: ""),
                                          activityCategory: BehaviorRelay<ActivityCategoryRepository>(value: ActivityCategoryRepository.Eating),
                                          activityName: BehaviorRelay<String>(value: ""))
