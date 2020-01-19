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

class DayDataModel {
    var itemUid: String
    var day: BehaviorRelay<Int>
    var date: BehaviorRelay<Date>
    
    init(itemUid: String, day: BehaviorRelay<Int>, date: BehaviorRelay<Date>) {
        self.itemUid = itemUid
        self.day = day
        self.date = date
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
