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
    let itemRealtionService = ItemRelationService()
    
    init() {
        // Dummy data
        do {
            // create travel schedule
            let realmTravelSchedule = withRealmDraft(RealmDraft.DaySchedule)
            if realmTravelSchedule.objects(DayScheduleItem.self).count == 0 {
                guard let thisTravel = DummyTravelItem else {
                    print("#Error - DummyTravelItem is nil!")
                    return
                }
                
                // Create dummy day schedule
                self.createDaySchedule(parent: thisTravel, day: 1, date: Date())
                    .flatMapLatest { res -> Observable<SpecificScheduleItem> in
                        // create dummy specific schedule
                        return self.createSpecificSchedule(parent: res, country: "Japan", city: "Tokyo", area: "Sinjuku", stTime: Date(), fnTime: Date(), placeCategory: PlaceCategoryRepository.Airport, placeName: "Narita Airport", activityCategory: ActivityCategoryRepository.Moving, activityName: "Moving")
                    }
                    .subscribe(onNext: { _ in
                        print("Dummy Schedule config")
                    })
                    .disposed(by: disposeBag)
            }
        } catch _ {
        }
    }
    
    @discardableResult
    func createDaySchedule(parent: TravelItem, day: Int, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.DaySchedule, "creating day schedule") { (realm) -> Observable<DayScheduleItem> in
            let daySchedule = DayScheduleItem()
            daySchedule.parentUid = parent.uid
            daySchedule.day = day
            daySchedule.date = date
            try realm.write {
                realm.add(daySchedule)
            }
            return .just(daySchedule)
        }?
        .do(onNext: { resDaySchedule in
            return self.itemRealtionService.createRelation(element: resDaySchedule)
        })
        .do(onNext: { resDaySchedule in
            return self.itemRealtionService.connectToLast(element: resDaySchedule)
        })
        
        return result ?? .error(ScheduleServiceError.creationFailed(DayScheduleItem.self))
    }
    
    @discardableResult
    func createSpecificSchedule(parent: DayScheduleItem, country: String, city: String, area: String, stTime: Date, fnTime: Date, placeCategory: PlaceCategoryRepository, placeName: String, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.SpecificSchedule, "creating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
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
            }?
            .do(onNext: { resSpecificSchedule in
                return self.itemRealtionService.createRelation(element: resSpecificSchedule)
            })
            .do(onNext: { resSpecificSchedule in
                return self.itemRealtionService.connectToLast(element: resSpecificSchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(SpecificScheduleItem.self))
    }
    
    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, day: Int, date: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.DaySchedule, "updating day schedule") { (realm) -> Observable<DayScheduleItem> in
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
        let result = withRealm(RealmDraft.SpecificSchedule, "updating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
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
    func deleteSchedule<T>(schedule: ScheduleItem, scheduleType: T.Type) -> Observable<Void> {
        var draft: RealmDraft
        
        if T.self is DayScheduleItem.Type {
            draft = RealmDraft.DaySchedule
        } else {
            draft = RealmDraft.SpecificSchedule
        }
        
        let result = itemRealtionService.disconnectRelation(element: schedule)
                .flatMapLatest { _ in
                    return self.withRealm(draft, "deleting schedule", action: { (realm) -> Observable<Void> in
                        try realm.write {
                            realm.delete(schedule)
                        }
                        return .empty()
                    }) ?? .error(ScheduleServiceError.deletionFailed(schedule))
                }
                .catchError { (error) -> Observable<Void> in
                    return .error(ScheduleServiceError.deletionFailed(schedule))
                }
        
        return result
    }
    
//    @discardableResult
//    func moveSchedule<T>(schedule: ScheduleItem, parent: ScheduleItem, nextToItem: ScheduleItem, scheduleType: T.Type) -> Observable<ScheduleItem> {
//        // TODO: Level Check is pre-required
//    }
    
    func getDaySchedule(dayScheduleUid: String) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.DaySchedule, "getting day schedule") { (realm) -> Observable<DayScheduleItem> in
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
        let result = withRealm(RealmDraft.DaySchedule, "getting day schedule of nth day") { (realm) -> Observable<DayScheduleItem> in
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
        let result = withRealm(RealmDraft.SpecificSchedule, "getting specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            let existData = realm.objects(SpecificScheduleItem.self).filter("uid = %@", specificScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(specificScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func daySchedules(ofParentScheduleUid: String) -> Observable<Results<DayScheduleItem>> {
        let result = withRealm(RealmDraft.DaySchedule, "getting day schedules of") { (realm) -> Observable<Results<DayScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.DaySchedule)
            let daySchedules = realm.objects(DayScheduleItem.self).filter("parentUid = %@", ofParentScheduleUid)
            return Observable.collection(from: daySchedules)
        }
        return result ?? .empty()
    }
    
    func specificSchedules(ofParentScheduleUid: String) -> Observable<Results<SpecificScheduleItem>> {
        let result = withRealm(RealmDraft.SpecificSchedule, "getting specific schedules of") { (realm) -> Observable<Results<SpecificScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.SpecificSchedule)
            let specificSchedules = realm.objects(SpecificScheduleItem.self).filter("parentUid = %@", ofParentScheduleUid)
            return Observable.collection(from: specificSchedules)
        }
        return result ?? .empty()
    }
    
    func getLastDay(ofParentUid: String) -> Observable<DayScheduleItem> {
        if let lastUid = itemRealtionService.getLastUid(parentUid: ofParentUid) {
            let result = withRealm(RealmDraft.DaySchedule, "getting last day element of travel") { (realm) -> Observable<DayScheduleItem> in
                let existData = realm.objects(DayScheduleItem.self).filter("uid = %@", lastUid)
                if let data = existData.first {
                    return .just(data)
                } else {
                    return .error(ScheduleServiceError.itemNotExistOfId(lastUid))
                }
            }
            return result ?? .empty()
        } else {
            return .error(ScheduleServiceError.itemIsNil)
        }
    }
}
