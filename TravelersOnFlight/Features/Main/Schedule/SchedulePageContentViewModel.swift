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

protocol receiveStepBelow { }

class SchedulePageContentViewModel: ServicesViewModel, Stepper, HasDisposeBag, receiveStepBelow {
    typealias Services = HasScheduleService

    let steps = PublishRelay<Step>()
    var services: Services!
    
    let thisDay: Int? 
    
    var dayItem: Observable<DayDataModel> {
        return self.services.scheduleService.getDaySchedule(ofNthDay: thisDay!)
            .map { item in
                return DayDataModel(itemUid: item.uid,
                                    day: BehaviorRelay<Int>(value: item.day),
                                    date: BehaviorRelay<Date>(value: item.date))
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
                        let specificData = specificItems.toArray().map { (item: SpecificScheduleItem) -> SpecificDataModel in
                        
                            let pc = PlaceCategoryRepository(rawValue: item.placeCategory) ?? PlaceCategoryRepository.Error
                            let ac = ActivityCategoryRepository(rawValue: item.activityCategory) ?? ActivityCategoryRepository.Error
                            
                            return SpecificDataModel(itemUid: item.uid,
                                                     countries: BehaviorRelay<String>(value: item.country),
                                                     cities: BehaviorRelay<String>(value: item.city),
                                                     areas: BehaviorRelay<String>(value: item.area),
                                                     stTime: BehaviorRelay<Date>(value: item.stTime),
                                                     fnTime: BehaviorRelay<Date>(value: item.fnTime),
                                                     placeCategory: BehaviorRelay<PlaceCategoryRepository>(value: pc),
                                                     placeName: BehaviorRelay<String>(value: item.placeName),
                                                     activityCategory: BehaviorRelay<ActivityCategoryRepository>(value: ac),
                                                     activityName: BehaviorRelay<String>(value: item.activityName))
                    }
                    
                    return [SpecificSection(model: "Specifics", items: specificData),
                            SpecificSection(model: "NewSpecific", items: [DummySpecificData])]
                }
    }

    init(day: Int) {
        self.thisDay = day
    }
    
    public func createItemOfSpecificSchedule(model: SpecificDataModel) {
        self.services.scheduleService.getDaySchedule(ofNthDay: thisDay!)
            .take(1)
            .subscribe(onNext: { (dayScheduleItem) in
                self.services.scheduleService.createSpecificSchedule(parent: dayScheduleItem,
                country: model.countries!.value,
                city: model.cities!.value,
                area: model.areas!.value,
                stTime: model.stTime!.value,
                fnTime: model.fnTime!.value,
                placeCategory: model.placeCategory!.value,
                placeName: model.placeName!.value,
                activityCategory: model.activityCategory!.value,
                activityName: model.activityName!.value)
            })
            .disposed(by: self.disposeBag)
    }
}
