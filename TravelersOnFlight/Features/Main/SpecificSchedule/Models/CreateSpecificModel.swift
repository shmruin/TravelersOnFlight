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
    
    func makeStTime() -> Observable<String> {
        let dateFormatter = timeDateFormatterHHmm()
        
        return stTime!.asObservable().map { dateFormatter.string(from: $0) }
    }
    
    func makeFnTime() -> Observable<String> {
        let dateFormatter = timeDateFormatterHHmm()
        
        return fnTime!.asObservable().map { dateFormatter.string(from: $0) }
    }
    
    func makeArea() -> Observable<String> {
        return areas!
                .asObservable()
                .map { res in
                    if res.isEmpty {
                        return "🖼Area"
                    } else {
                        return "🖼\(res)"
                    }
                }
    }
    
    func makeCity() -> Observable<String> {
        return cities!
                .asObservable()
                .map { res in
                    if res.isEmpty {
                        return "🏙City"
                    } else {
                        return "🏙\(res)"
                    }
                }
    }
    
    func makeCountry() -> Observable<String> {
        return countries!
                .asObservable()
                .map { res in
                    if res.isEmpty {
                        return "🗺Country"
                    } else {
                        return Common.getFlag(countryName: res)
                    }
                }
    }
    
    func makePlaceCategory() -> Observable<String> {
        return placeCategory!.asObservable().map { $0.rawValue }
    }
    
    func makePlaceName() -> Observable<String> {
        return placeName!.asObservable()
    }
    
    func makeActivityCategory() -> Observable<String> {
        return activityCategory!.asObservable().map { $0.rawValue }
    }
    
    func makeActivityName() -> Observable<String> {
        return activityName!.asObservable()
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

let DummySpecificUid = Common.makeUid()

// Use for 'new' section
let DummySpecificData = SpecificDataModel(itemUid: DummySpecificUid,
                                          countries: BehaviorRelay<String>(value: ""),
                                          cities: BehaviorRelay<String>(value: ""),
                                          areas: BehaviorRelay<String>(value: ""),
                                          stTime: BehaviorRelay<Date>(value: Date()),
                                          fnTime: BehaviorRelay<Date>(value: Date()),
                                          placeCategory: BehaviorRelay<PlaceCategoryRepository>(value: PlaceCategoryRepository.Select),
                                          placeName: BehaviorRelay<String>(value: ""),
                                          activityCategory: BehaviorRelay<ActivityCategoryRepository>(value: ActivityCategoryRepository.Select),
                                          activityName: BehaviorRelay<String>(value: ""))
