//
//  SchedulePageContentViewModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/10/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import RxFlow
import RxSwift
import RxSwiftExt
import RxDataSources
import RxCocoa
import RealmSwift
import NSObject_Rx

typealias SpecificSection = AnimatableSectionModel<String, SpecificDataModel>

class SchedulePageContentViewModel: ServicesViewModel, Stepper, HasDisposeBag {
    typealias Services = HasScheduleService

    let steps = PublishRelay<Step>()
    var services: Services!
    
    let thisDay: Int?
    
    var dayItem: Observable<DayDataModel> {
        return self.services.scheduleService.getDaySchedule(ofNthDay: thisDay!)
            .map { item in
                return DayDataModel(itemUid: item.uid,
                                    day: BehaviorRelay<Date>(value: item.day))
            }
    }
    
    // Collections of specific
    var collectionItems: Observable<[SpecificSection]> {
        return dayItem
                .flatMapLatest { item -> Observable<DayScheduleItem> in
                    return self.services.scheduleService.getDaySchedule(dayScheduleUid: item.itemUid)
                }
                .flatMapLatest { daySchedule -> Observable<Results<SpecificScheduleItem>> in
                    return self.services.scheduleService.specificSchedules(ofDaySchedule: daySchedule)
                }
                .map { results in
                    let specificItems = results.sorted(byKeyPath: "stTime", ascending: true)
                    let specificData = specificItems.toArray().map { (item: SpecificScheduleItem) in
                        return SpecificDataModel(itemUid: item.uid,
                                                 countries: BehaviorRelay<String>(value: item.country),
                                                 cities: BehaviorRelay<String>(value: item.city),
                                                 stTime: BehaviorRelay<Date>(value: item.stTime),
                                                 fnTime: BehaviorRelay<Date>(value: item.fnTime))
                    }
                    
                    return [SpecificSection(model: "Specifics", items: specificData),
                            SpecificSection(model: "NewSpecific", items: [DummySpecificData])]
                }
    }

    init(day: Int) {
        self.thisDay = day
    }
    
}
