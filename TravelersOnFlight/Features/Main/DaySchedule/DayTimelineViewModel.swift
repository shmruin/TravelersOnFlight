//
//  DayTimelineViewModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 01/02/2020.
//  Copyright © 2020 ruin09. All rights reserved.
//

import RxFlow
import RxSwift
import RxSwiftExt
import RxDataSources
import RxCocoa
import NSObject_Rx

typealias DaySection = AnimatableSectionModel<String, DayDataModel>

class DayTimelineViewModel: ServicesViewModel, Stepper, HasDisposeBag {
    typealias Services = HasTravelScheduleService

    let steps = PublishRelay<Step>()
    var services: Services!
    
    var thisTravelUid: String? = nil
    
    var collectionItems: Observable<[DaySection]> {
        return self.services.scheduleService.daySchedules(ofParentScheduleUid: thisTravelUid!)
            .map { results in
                let dayItems = results.sorted(byKeyPath: "day", ascending: false)
                let dayData = dayItems.toArray().map { (item: DayScheduleItem) in
                    return DayDataModel(itemUid: item.uid,
                                        day: BehaviorRelay<Int>(value: item.day),
                                        date: BehaviorRelay<Date>(value: item.date),
                                        description: BehaviorRelay<String>(value: ""))
                }
                
                return [DaySection(model: "Days", items: dayData),
                        DaySection(model: "NewDay", items: [dummyDayData])]
            }
    }
    
    init(thisTravelUid: String) {
        self.thisTravelUid = thisTravelUid
    }
    
    func selectToSpecificSchedule(dayData: DayDataModel) {
        self.steps.accept(TravelStep.dayIsSelected(withDayData: dayData))
    }
    
    public func createItemOfDayScehdule() {
        self.services.travelService.getTravel(travelUid: thisTravelUid!)
            .flatMapLatest { travelItem in
                return self.services.scheduleService.getLastDay(ofParentUid: travelItem.uid).map { (travelItem, $0) }
            }
            .subscribe(onNext: { item in
                self.services.scheduleService.createDaySchedule(parent: item.0,
                                                                day: item.1.day + 1,
                                                                date: Common.increaseOneDateFeature(targetDate: item.1.date, feature: .day, value: 1))
            })
            .disposed(by: self.disposeBag)
    }
}
