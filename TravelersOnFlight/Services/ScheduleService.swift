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

protocol HasTravelScheduleService {
    var travelService: TravelService { get }
    var scheduleService: ScheduleService { get }
}

private let disposeBag = DisposeBag()

class ScheduleService: ScheduleServiceType {
    
    init() { }
    
    @discardableResult
    func createDaySchedule(parent: TravelItem, day: Int, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating day schedule") { (realm) -> Observable<DayScheduleItem> in
            let daySchedule = DayScheduleItem()
            daySchedule.parentUid = parent.uid
            daySchedule.day = day
            daySchedule.date = date
            try realm.write {
                realm.add(daySchedule)
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
            }
            
            return .just(specificSchedule)
        }
        
        return result ?? .error(ScheduleServiceError.creationFailed(SpecificScheduleItem.self))
    }
    
    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, day: Int, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "updating day schedule") { (realm) -> Observable<DayScheduleItem> in
            try realm.write {
                daySchedule.day = day
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
            msg = "deleting day schedule"
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
    
    func getDaySchedule(ofNthDay: Int) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting day schedule of nth day") { (realm) -> Observable<DayScheduleItem> in
            let existData = realm.objects(DayScheduleItem.self).filter("day = %@", ofNthDay)
            if existData.count > 1 {
                return .error(CommonRealmError.duplicatedUniqueValue("day"))
            }
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfCondition)
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
        let result = TravelService().getTravel(travelUid: ofParentUid)
            .catchError({ (error) -> Observable<TravelItem> in
                return .error(TravelServiceError.gettingFailed)
            })
            .flatMapLatest { travelItem -> Observable<DayScheduleItem?> in
                if travelItem is Error {
                    return .error(ScheduleServiceError.gettingLastDayFailed)
                } else {
                    return self.withRealm(RealmDraft.TravelersOnFlight, "getting last day element of travel", action:  { (realm) -> Observable<DayScheduleItem?> in
                        if !travelItem.dayItems.isEmpty {
                            return .just(travelItem.dayItems.last)
                        } else {
                            // day for this travel is empty => return nil
                            return .just(nil)
                        }
                    }) ?? .error(ScheduleServiceError.gettingLastDayFailed)
                }
            }
            .catchError { (error) -> Observable<DayScheduleItem?> in
                return .error(ScheduleServiceError.gettingLastDayFailed)
            }
        
        return result
    }
}
