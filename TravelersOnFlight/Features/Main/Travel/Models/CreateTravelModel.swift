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
    
    var dataSource: Observable<TravelItem>?
    
    var travelTitleObservable: Observable<String> {
        return Observable.combineLatest(stDate.asObservable(),
                 cities.asObservable(),
                 theme.asObservable())
        .map { (date, cities, theme)  in
            return "\(date?.formatMonth ?? "-"), \(cities.first ?? "-"), \(theme)"
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
    init(itemUid: String, dataSource: Observable<TravelItem>?) {
        self.itemUid = itemUid
        self.dataSource = dataSource
        
        _ = dataSource?.map { Array($0.countries) }.bind(to: countries)
        _ = dataSource?.map { Array($0.cities) }.bind(to: cities)
        _ = dataSource?.map { TravelTheme(rawValue: $0.theme) ?? TravelTheme.getDefault() }.bind(to: theme)
        _ = dataSource?.map { $0.dayItems.first?.date ?? nil }.bind(to: stDate)
        _ = dataSource?.map { $0.dayItems.last?.date ?? nil }.bind(to: fnDate)
        
        dataSource?
            .subscribe(onNext: { _ in
                print("Travel Data Model of \(itemUid) on next called")
            })
            .disposed(by: self.disposeBag)
        
    }
        
    func makeTravelSummary(_ nDay: Int, _ nCountry: Int, _ nCity: Int) -> String {
        let suffixDays = nDay > 1 ? "days" : "day"
        let suffixCountries = nCountry > 1 ? "countries" : "country"
        let suffixCities = nCity > 1 ? "cities" : "city"
        
        return "\(nDay) \(suffixDays) on \(nCountry) \(suffixCountries), \(nCity) \(suffixCities)"
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
let DummyTravelData = TravelDataModel(itemUid: DummyTravelUid, dataSource: nil)
