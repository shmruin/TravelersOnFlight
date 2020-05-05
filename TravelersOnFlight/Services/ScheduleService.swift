//
//  ScheduleService.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 30/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

protocol HasScheduleService {
    var scheduleService: ScheduleService { get }
}

private let disposeBag = DisposeBag()

struct ScheduleService: ScheduleServiceType {
    
    init() { }
    
    @discardableResult
    func createDaySchedule(parent: TravelItem, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating day schedule") { (realm) -> Observable<DayScheduleItem> in
            let daySchedule = DayScheduleItem()
            daySchedule.parentUid = parent.uid
            daySchedule.date = date
            try realm.write {
                realm.add(daySchedule)
                parent.dayItems.append(daySchedule)
            }
            
            return .just(daySchedule)
        }
        
        return result ?? .error(ScheduleServiceError.creationFailed(DayScheduleItem.self))
    }
    
    @discardableResult
    func createSpecificSchedule(parent: DayScheduleItem, country: String, city: String, area: String, stTime: Date, fnTime: Date, placeCategory: PlaceCategoryRepository, placeName: String, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            let specificSchedule = SpecificScheduleItem()
            specificSchedule.parentUid = parent.uid
            specificSchedule.country = country
            specificSchedule.city = city
            specificSchedule.area = area
            specificSchedule.stTime = stTime
            specificSchedule.fnTime = fnTime
            specificSchedule.placeCategory = placeCategory.rawValue
            specificSchedule.placeName = placeName
            specificSchedule.activityCategory = activityCategory.rawValue
            specificSchedule.activityName = activityName
            
            try realm.write {
                realm.add(specificSchedule)
                parent.specificItems.append(specificSchedule)
            }
            
            return .just(specificSchedule)
        }
        
        return result ?? .error(ScheduleServiceError.creationFailed(SpecificScheduleItem.self))
    }
    
    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "updating day schedule") { (realm) -> Observable<DayScheduleItem> in
            try realm.write {
                daySchedule.date = date
            }
            return .just(daySchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(daySchedule))
    }
    
    @discardableResult
    func updateSpecificSchedule(specificSchedule: SpecificScheduleItem, country: String, city: String, area: String, stTime: Date, fnTime: Date, placeCategory: PlaceCategoryRepository, placeName: String, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "updating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            try realm.write {
                specificSchedule.country = country
                specificSchedule.city = city
                specificSchedule.area = area
                specificSchedule.stTime = stTime
                specificSchedule.fnTime = fnTime
                specificSchedule.placeCategory = placeCategory.rawValue
                specificSchedule.placeName = placeName
                specificSchedule.activityCategory = activityCategory.rawValue
                specificSchedule.activityName = activityName
            }
            return .just(specificSchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(specificSchedule))
    }
    
    @discardableResult
    func deleteSchedule(schedule: ScheduleItem) -> Observable<Void> {
        
        var msg = ""
        
        if schedule is DayScheduleItem {
            msg = "deleting day schedule"
        } else if schedule is SpecificScheduleItem {
            msg = "deleting specific schedule"
        } else {
            msg = "deleteing undefined schedule!"
        }
        
        let result = withRealm(RealmDraft.TravelersOnFlight, msg, action: { (realm) -> Observable<Void> in
                try realm.write {
                    realm.delete(schedule, cascading: true)
                }
                return .empty()
        }) ?? .error(ScheduleServiceError.deletionFailed(schedule))
        
        return result
    }
    
    @discardableResult
    func insertDayScheduleToParent(parent: TravelItem, date: Date) -> Observable<DayScheduleItem?> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "inserting day schedule") { (realm) -> Observable<DayScheduleItem?> in
            /**
            * Check duplicatied day
            */
            for item in parent.dayItems {
                if item.date.isEqualDay(.day, as: date) {
                    return .just(nil)
                }
            }
            
            let daySchedule = DayScheduleItem()
            daySchedule.parentUid = parent.uid
            daySchedule.date = date
            
            try realm.write {
                realm.add(daySchedule)
                parent.dayItems.append(daySchedule)
                let newArr = Array(parent.dayItems.sorted(byKeyPath: "date", ascending: true))
                parent.dayItems.removeAll()
                parent.dayItems.append(objectsIn: newArr)
            }
            
            return .just(daySchedule)
        }
        
        return result ?? .just(nil)
    }
    
    func getDaySchedule(dayScheduleUid: String) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting day schedule") { (realm) -> Observable<DayScheduleItem> in
            let existData = realm.objects(DayScheduleItem.self).filter("uid = %@", dayScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(dayScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func getDaySchedule(parentUid: String, ofNthDayFromOne: Int) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting day schedule of nth day") { (realm) -> Observable<DayScheduleItem> in
            let existData = realm.objects(TravelItem.self).filter("uid = %@", parentUid)
            if let data = existData.first { // Parent travel of wanted day
                if data.dayItems.count < ofNthDayFromOne {
                    return .error(ScheduleServiceError.dayNotInTravelItem)
                } else {
                    return .just(data.dayItems[ofNthDayFromOne - 1])
                }
            } else {
                return .error(TravelServiceError.itemNotExistOfId(parentUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func getSpecificSchedule(specificScheduleUid: String) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            let existData = realm.objects(SpecificScheduleItem.self).filter("uid = %@", specificScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(specificScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func daySchedules(ofParentTravelUid: String) -> Observable<Results<DayScheduleItem>> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting day schedules of") { (realm) -> Observable<Results<DayScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
            let daySchedules = realm.objects(DayScheduleItem.self).filter("parentUid = %@", ofParentTravelUid)
            return Observable.collection(from: daySchedules)
        }
        return result ?? .empty()
    }
    
    func specificSchedules(ofParentScheduleUid: String) -> Observable<Results<SpecificScheduleItem>> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting specific schedules of") { (realm) -> Observable<Results<SpecificScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
            let specificSchedules = realm.objects(SpecificScheduleItem.self).filter("parentUid = %@", ofParentScheduleUid)
            return Observable.collection(from: specificSchedules)
        }
        return result ?? .empty()
    }
    
    func getLastDay(ofParentUid: String) -> Observable<DayScheduleItem?> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting last day element of travel") { (realm) -> Observable<DayScheduleItem?> in
            let existData = realm.objects(TravelItem.self).filter("uid = %@", ofParentUid)
            if let data = existData.first { // parent travel of wanted day
                if data.dayItems.isEmpty {  // if days are empty, first day
                    return .just(nil)
                } else {
                    return .just(data.dayItems.last)
                }
            } else {    // parent travel not exist
                return .error(TravelServiceError.itemNotExistOfId(ofParentUid))
            }
        }
        
        return result ?? .error(ScheduleServiceError.gettingLastDayFailed)
    }
    
    func getNthOfDaySchedule(daySchedule: DayScheduleItem) -> Observable<Int?> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting nth of this day schedule") { (realm) -> Observable<Int?> in
            let existData = realm.objects(TravelItem.self).filter("uid = %@", daySchedule.parentUid)
            if let data = existData.first {
                for (idx, item) in data.dayItems.enumerated() {
                    if item.uid == daySchedule.uid {
                        return .just(idx + 1)
                    }
                }
                return .error(ScheduleServiceError.dayNotInTravelItem)
            } else {    // day parent not exist
                return .error(TravelServiceError.itemNotExistOfId(daySchedule.parentUid))
            }
        }
        
        return result ?? .error(ScheduleServiceError.getNthOfDayScheduleFailed)
    }
}
