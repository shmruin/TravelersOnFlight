//
//  CreateDayDataModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 01/11/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx

class DayDataModel : HasDisposeBag {
    
    var itemUid: String
    var day : BehaviorRelay<Int>
    var date: BehaviorRelay<Date>
    var description: BehaviorRelay<String>
    
    init(itemUid: String, day: BehaviorRelay<Int>, date: BehaviorRelay<Date>, description: BehaviorRelay<String>) {
        self.itemUid = itemUid
        self.day = day
        self.date = date
        self.description = description
    }
}

extension DayDataModel: IdentifiableType {
    var identity: String {
        return itemUid
    }
}

extension DayDataModel: Equatable {
    static func == (lhs: DayDataModel, rhs: DayDataModel) -> Bool {
        return lhs.itemUid == rhs.itemUid
    }
}

var dummyDayData = DayDataModel(itemUid: Common.makeUid(),
                                day: BehaviorRelay<Int>(value: 0),
                                date: BehaviorRelay<Date>(value: Date()),
                                description: BehaviorRelay<String>(value: ""))
