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

class TravelDataModel {
    var itemUid: String
    var countries: BehaviorRelay<[String]>?
    var cities: BehaviorRelay<[String]>?
    var theme: BehaviorRelay<TravelTheme>?
    var stDate: BehaviorRelay<Date>?
    var fnDate: BehaviorRelay<Date>?
    
    init(itemUid: String, countries: BehaviorRelay<[String]>, cities: BehaviorRelay<[String]>,
         theme: BehaviorRelay<TravelTheme>, stDate: BehaviorRelay<Date>, fnDate: BehaviorRelay<Date>) {
        self.itemUid = itemUid
        self.countries = countries
        self.cities = cities
        self.theme = theme
        self.stDate = stDate
        self.fnDate = fnDate
    }
    
    func stDateToStringYYMMDD() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        if let res = self.stDate?.value {
            return dateFormatter.string(from: res)
        } else {
            print("#ERROR - TravelCreateData stDate is nil")
            return nil
        }
    }
    
    func fnDateToStringYYMMDD() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        if let res = self.fnDate?.value {
            return dateFormatter.string(from: res)
        } else {
            print("#ERROR - TravelCreateData fnDate is nil")
            return nil
        }
    }
    
    func makeTravelTitle() -> String {
        if let fc = cities?.value.first, let st = stDate?.value, let th = theme?.value {
            return "\(st.formatMonth), \(fc), \(th)"
        } else {
            print("#ERROR - makeTravelTitle something is nil")
            return "*Title Error*"
        }
    }
    
    func makeTravelSummary() -> String {
        if let st = stDate?.value, let fn = fnDate?.value, let nCountries = countries?.value.count, let nCities = countries?.value.count {
            let days = fn.days(sinceDate: st)!
            
            let suffixDays = days > 1 ? "days" : "day"
            let suffixCountries = nCountries > 1 ? "countries" : "country"
            let suffixCities = nCities > 1 ? "cities" : "city"
            
            return "\(days) \(suffixDays) on \(nCountries) \(suffixCountries), \(nCities) \(suffixCities)"
        } else {
            print("#ERROR - makeTravelSummary something is nil")
            return "*Summary Error *"
        }
    }
    
    func makeTravelDates() -> String {
        if let dt = fnDate?.value {
            let stringDate = dt.formatString(with: "yy.MM.dd")
            return "\(stringDate)"
        } else {
            print("#ERROR - makeTravelDates something is nil")
            return "*Date Error*"
        }
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

let DummyTravelData = TravelDataModel(itemUid: TravelItem.makeUid(),
                                      countries: BehaviorRelay<[String]>(value: [""]),
                                      cities: BehaviorRelay<[String]>(value: [""]),
                                      theme: BehaviorRelay<TravelTheme>(value: TravelTheme.Unexpected),
                                      stDate: BehaviorRelay<Date>(value: Date()),
                                      fnDate: BehaviorRelay<Date>(value: Date()))
