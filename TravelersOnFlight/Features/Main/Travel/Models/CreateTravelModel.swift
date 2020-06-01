//
//  CreateFormModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 13/09/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx

class TravelDataModel: HasDisposeBag {
    var itemUid: String
    var countries = BehaviorRelay<[String]>(value: [])
    var cities = BehaviorRelay<[String]>(value: [])
    var theme = BehaviorRelay<TravelTheme>(value: TravelTheme.getDefault())
    var stDate = BehaviorRelay<Date?>(value: nil)
    var fnDate = BehaviorRelay<Date?>(value: nil)
    
    var travelDataSource: Observable<TravelItem>?
    var countryDataSource: Observable<[String]>?
    var cityDataSource: Observable<[String]>?
    
    var travelTitleObservable: Observable<String> {
        return Observable.combineLatest(stDate.asObservable(),
                 cities.asObservable(),
                 theme.asObservable())
        .map { (date, cities, theme)  in
            return "\(date?.formatMonth ?? "-"), \(cities.first ?? "-"), \(theme)"
        }
    }
    
    var travelSummaryObservable: Observable<String> {
        return Observable.combineLatest(stDate.asObservable(),
                                        fnDate.asObservable(),
                                        countries.asObservable(),
                                        cities.asObservable())
            .map { (stDate, fnDate, countries, cities) in
                var nDay = 0
                
                if let sDate = stDate, let fDate = fnDate {
                    nDay = sDate.distanceIntOf(targetDate: fDate) + 1
                } else {
                    print("#ERROR - stDate or fnDate is nil")
                }
                let nCountry = countries.count
                let nCity = cities.count
                
                let suffixDays = nDay > 1 ? "days" : "day"
                let suffixCountries = nCountry > 1 ? "countries" : "country"
                let suffixCities = nCity > 1 ? "cities" : "city"
                
                return "\(nDay) \(suffixDays) on \(nCountry) \(suffixCountries), \(nCity) \(suffixCities)"
            }
    }
    
    /**
     * Init for new travel
     */
    init(itemUid: String,
         countries: BehaviorRelay<[String]>,
         cities: BehaviorRelay<[String]>,
         theme: BehaviorRelay<TravelTheme>,
         stDate: BehaviorRelay<Date?>,
         fnDate: BehaviorRelay<Date?>) {
        self.itemUid = itemUid
        self.countries = countries
        self.cities = cities
        self.theme = theme
        self.stDate = stDate
        self.fnDate = fnDate
    }
    
    /**
     * init for model binding
     */
    init(itemUid: String,
         travelDataSource: Observable<TravelItem>?,
         countryDataSource: Observable<[String]>?,
         cityDataSource: Observable<[String]>?) {
        
        self.itemUid = itemUid
        self.travelDataSource = travelDataSource
        self.countryDataSource = countryDataSource
        self.cityDataSource = cityDataSource
        
        _ = countryDataSource?.catchErrorJustComplete().bind(to: countries)
        _ = cityDataSource?.catchErrorJustComplete().bind(to: cities)
        _ = travelDataSource?.catchErrorJustComplete().map { TravelTheme(rawValue: $0.theme) ?? TravelTheme.getDefault() }.bind(to: theme)
        _ = travelDataSource?.catchErrorJustComplete().map { $0.dayItems.first?.date ?? nil }.bind(to: stDate)
        _ = travelDataSource?.catchErrorJustComplete().map { $0.dayItems.last?.date ?? nil }.bind(to: fnDate)
        
//        travelDataSource?
//            .subscribe(onNext: { _ in
//                print("Travel Data Model of \(itemUid) on next called")
//            })
//            .disposed(by: self.disposeBag)
        
    }
}

extension TravelDataModel: IdentifiableType {
    var identity: String {
        return itemUid
    }
}

extension TravelDataModel: Equatable {
    static func == (lhs: TravelDataModel, rhs: TravelDataModel) -> Bool {
        return lhs.itemUid == rhs.itemUid
    }
}

let DummyTravelUid = Common.makeUid()

// Use for 'new' section
let DummyTravelData = TravelDataModel(itemUid: DummyTravelUid, travelDataSource: nil, countryDataSource: nil, cityDataSource: nil)
