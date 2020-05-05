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
    typealias Services = HasTravelService

    let steps = PublishRelay<Step>()
    var services: Services!
    
    var thisTravelUid: String? = nil
    var dayBehaviorDict: [String : BehaviorRelay<Int>] = [:]
    
    var collectionItems: Observable<[DaySection]> {
        return self.services.scheduleService.daySchedules(ofParentTravelUid: thisTravelUid!)
            .map { results in
                let dayItems = results.sorted(byKeyPath: "date", ascending: true)
                let dayData = dayItems.toArray().map { (item: DayScheduleItem) -> DayDataModel in
                    
                    return DayDataModel(itemUid: item.uid,
                                        day: self.getDayForModel(item),
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
    
    private func getDayForModel(_ daySchedule: DayScheduleItem) -> BehaviorRelay<Int> {
        
        var newDayRelay: BehaviorRelay<Int>? = nil
        
        if let dayRelay = dayBehaviorDict[daySchedule.uid] {
            newDayRelay = dayRelay
        } else {
            newDayRelay = BehaviorRelay<Int>(value: 0)
        }
        
        self.services.scheduleService.getNthOfDaySchedule(daySchedule: daySchedule)
        .subscribe(onNext: { res in
            if let res = res {
                newDayRelay!.accept(res)
                print(res)
            } else {
                fatalError("#ERROR - cannot find day of this day schedule")
            }
        })
        .disposed(by: self.disposeBag)
        
        dayBehaviorDict[daySchedule.uid] = newDayRelay
        return newDayRelay!
    }
    
    func selectToSpecificSchedule(dayData: DayDataModel) {
        self.steps.accept(TravelStep.dayIsSelected(withDayData: dayData))
    }
    
    public func createItemOfDayScehdule() {
        self.services.travelService.getTravel(travelUid: thisTravelUid!)
            .flatMap { travelItem -> Observable<(TravelItem, DayScheduleItem?)> in
                return self.services.scheduleService.getLastDay(ofParentUid: travelItem.uid).map { (travelItem, $0) }
            }
            .flatMap { item -> Observable<DayScheduleItem> in
                if let existDay = item.1 {
                    print("create recent day")
                    return self.services.scheduleService.createDaySchedule(parent: item.0,
                                                            date: Common.increaseOneDateFeature(targetDate: existDay.date, feature: .day, value: 1))
                } else {
                    print("create new day")
                    return self.services.scheduleService.createDaySchedule(parent: item.0,
                                                                           date: Date())
                }
            }
            .subscribe({ _ in
                print("Day schedule created")
            })
            .disposed(by: self.disposeBag)
    }
    
    public func insertItemOfDaySchedule(_ date: Date, onFailure: @escaping ()->()) {
        self.services.travelService.getTravel(travelUid: thisTravelUid!)
        .flatMap { travelItem -> Observable<DayScheduleItem?> in
                print("insert a day")
                return self.services.scheduleService.insertDayScheduleToParent(parent: travelItem, date: date)
        }
        .subscribe(onNext: { res in
            if res != nil {
                print("Day schedule inserted")
            } else {
                onFailure()
                print("Day insertion fail - it aleady exists!")
            }
        })
        .disposed(by: self.disposeBag)
    }
    
    public func deleteItemOfDaySchedule(model: DayDataModel) {
        self.services.scheduleService.getDaySchedule(dayScheduleUid: model.itemUid)
            .flatMapLatest { dayItem -> Observable<Void> in
                print(dayItem.uid)
                print("!!!")
                self.dayBehaviorDict[dayItem.uid] = nil
                return self.services.scheduleService.deleteSchedule(schedule: dayItem)
            }
            .subscribe({ _ in
                print("Day schedule is deleted")
                print(self.dayBehaviorDict)
            })
            .disposed(by: self.disposeBag)
    }
}
