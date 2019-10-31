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

class ScheduleService: ScheduleServiceType {
    let itemRealtionService = ItemRelationService()
    
    init() {
        // Dummy data
        do {
            // create travel schedule
            let realmTravelSchedule = withRealmDraft(RealmDraft.TravelSchedule)
            if realmTravelSchedule.objects(TravelScheduleItem.self).count == 0 {
                guard let thisTravel = DummyTravelItem else {
                    print("#Error - DummyTravelItem is nil!")
                    return
                }
                
                [(thisTravel)].forEach {
                    self.createTravelSchedule(parent: $0)
                        // create dummy day
                        .flatMapLatest { travelSchedule -> Observable<DayScheduleItem> in
                            self.itemRealtionService.createRelation(parentUid: travelSchedule.uid)
                            self.itemRealtionService.connectToLast(element: thisTravel)
                            return self.createDaySchedule(parent: travelSchedule, day: Date())
                        }
                        // create dummy specific
                        .flatMapLatest { daySchedule -> Observable<SpecificScheduleItem> in
                            self.itemRealtionService.createRelation(parentUid: daySchedule.uid)
                            self.getTravelSchedule(travelScheduleUid: daySchedule.parentUid)
                                .take(1)
                                .subscribe(onNext: { res in
                                    self.itemRealtionService.connectToLast(element: res)
                                })
                                .disposed(by: disposeBag)
                            return self.createSpecificSchedule(parent: daySchedule, country: "Japan", city: "Tokyo", stTime: Date(), fnTime: Date())
                        }
                        // create dummy specific
                        .flatMapLatest { specificSchedule -> Observable<PlaceScheduleItem> in
                            self.itemRealtionService.createRelation(parentUid: specificSchedule.uid)
                            self.getDaySchedule(dayScheduleUid: specificSchedule.parentUid)
                                .take(1)
                                .subscribe(onNext: { res in
                                    self.itemRealtionService.connectToLast(element: res)
                                })
                                .disposed(by: disposeBag)
                            return self.createPlaceSchedule(parent: specificSchedule, placeCategory: PlaceCategoryRepository.Airport, placeName: "나리타 공항")
                        }
                        // create dummy specific
                        .flatMapLatest { placeSchedule -> Observable<ActivityScheduleItem> in
                            self.itemRealtionService.createRelation(parentUid: placeSchedule.uid)
                            self.getSpecificSchedule(specificScheduleUid: placeSchedule.parentUid)
                                .take(1)
                                .subscribe(onNext: { res in
                                    self.itemRealtionService.connectToLast(element: res)
                                })
                                .disposed(by: disposeBag)
                            return self.createActivitySchedule(parent: placeSchedule, activityCategory: ActivityCategoryRepository.Moving, activityName: "이동하기")
                        }
                        .subscribe(onNext: { activitySchedule in
                            self.itemRealtionService.createRelation(parentUid: activitySchedule.uid)
                            self.getPlaceSchedule(placeScheduleUid: activitySchedule.parentUid)
                            .take(1)
                            .subscribe(onNext: { res in
                                self.itemRealtionService.connectToLast(element: res)
                            })
                            .disposed(by: disposeBag)
                        })
                        .disposed(by: disposeBag)
                }
            }
        } catch _ {
        }
    }
    
    @discardableResult
    func createTravelSchedule(parent: TravelItem) -> Observable<TravelScheduleItem> {
        let result = withRealm(RealmDraft.TravelSchedule, "creating travel schedule") { (realm) -> Observable<TravelScheduleItem> in
            let travelSchedule = TravelScheduleItem()
            travelSchedule.parentUid = parent.uid
            try realm.write {
                realm.add(travelSchedule)
            }
            return .just(travelSchedule)
            }?
            .do(onNext: { resTravelSchedule in
                return self.itemRealtionService.connectToLast(element: resTravelSchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(TravelScheduleItem.self))
    }
    
    @discardableResult
    func createDaySchedule(parent: TravelScheduleItem, day: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.DaySchedule, "creating day schedule") { (realm) -> Observable<DayScheduleItem> in
            let daySchedule = DayScheduleItem()
            daySchedule.parentUid = parent.uid
            daySchedule.day = day
            try realm.write {
                realm.add(daySchedule)
            }
            return .just(daySchedule)
            }?
            .do(onNext: { resDaySchedule in
                return self.itemRealtionService.connectToLast(element: resDaySchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(DayScheduleItem.self))
    }
    
    @discardableResult
    func createSpecificSchedule(parent: DayScheduleItem, country: String, city: String, stTime: Date, fnTime: Date) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.SpecificSchedule, "creating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            let specificSchedule = SpecificScheduleItem()
            specificSchedule.parentUid = parent.uid
            specificSchedule.country = country
            specificSchedule.city = city
            specificSchedule.stTime = stTime
            specificSchedule.fnTime = fnTime
            try realm.write {
                realm.add(specificSchedule)
            }
            return .just(specificSchedule)
            }?
            .do(onNext: { resSpecificSchedule in
                return self.itemRealtionService.connectToLast(element: resSpecificSchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(SpecificScheduleItem.self))
    }
    
    @discardableResult
    func createPlaceSchedule(parent: SpecificScheduleItem, placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem> {
        let result = withRealm(RealmDraft.PlaceSchedule, "creating place schedule") { (realm) -> Observable<PlaceScheduleItem> in
            let placeSchedule = PlaceScheduleItem()
            placeSchedule.parentUid = parent.uid
            placeSchedule.placeCategory = placeCategory.rawValue
            placeSchedule.placeName = placeName
            try realm.write {
                realm.add(placeSchedule)
            }
            return .just(placeSchedule)
            }?
            .do(onNext: { resPlaceSchedule in
                return self.itemRealtionService.connectToLast(element: resPlaceSchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(PlaceScheduleItem.self))
    }
    
    @discardableResult
    func createActivitySchedule(parent: PlaceScheduleItem, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem> {
        let result = withRealm(RealmDraft.ActivitySchedule, "creating activity schedule") { (realm) -> Observable<ActivityScheduleItem> in
            let activitySchedule = ActivityScheduleItem()
            activitySchedule.parentUid = parent.uid
            activitySchedule.activityCategory = activityCategory.rawValue
            activitySchedule.activityName = activityName
            try realm.write {
                realm.add(activitySchedule)
            }
            return .just(activitySchedule)
            }?
            .do(onNext: { resActivitySchedule in
                return self.itemRealtionService.connectToLast(element: resActivitySchedule)
            })
        
        return result ?? .error(ScheduleServiceError.creationFailed(ActivityScheduleItem.self))
    }
    
    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, day: Date) -> Observable<DayScheduleItem> {
        let result = withRealm(RealmDraft.DaySchedule, "updating day schedule") { (realm) -> Observable<DayScheduleItem> in
            try realm.write {
                daySchedule.day = day
            }
            return .just(daySchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(daySchedule))
    }
    
    @discardableResult
    func updateSpecificSchedule(specificSchedule: SpecificScheduleItem, country: String, city: String, stTime: Date, fnTime: Date) -> Observable<SpecificScheduleItem> {
        let result = withRealm(RealmDraft.SpecificSchedule, "updating specific schedule") { (realm) -> Observable<SpecificScheduleItem> in
            try realm.write {
                specificSchedule.country = country
                specificSchedule.city = city
                specificSchedule.stTime = stTime
                specificSchedule.fnTime = fnTime
            }
            return .just(specificSchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(specificSchedule))
    }
    
    @discardableResult
    func updatePlaceSchedule(placeSchedule: PlaceScheduleItem, placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem> {
        let result = withRealm(RealmDraft.PlaceSchedule, "updating place schedule") { (realm) -> Observable<PlaceScheduleItem> in
            try realm.write {
                placeSchedule.placeCategory = placeCategory.rawValue
                placeSchedule.placeName = placeName
            }
            return .just(placeSchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(placeSchedule))
    }
    
    @discardableResult
    func updateActivitySchedule(activitySchedule: ActivityScheduleItem, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem> {
        let result = withRealm(RealmDraft.ActivitySchedule, "updating activity schedule") { (realm) -> Observable<ActivityScheduleItem> in
            try realm.write {
                activitySchedule.activityCategory = activityCategory.rawValue
                activitySchedule.activityName = activityName
            }
            return .just(activitySchedule)
        }
        return result ?? .error(ScheduleServiceError.updateFailed(activitySchedule))
    }
    
    @discardableResult
    func deleteSchedule<T>(schedule: ScheduleItem, scheduleType: T.Type) -> Observable<Void> {
        var draft: RealmDraft
        if T.self is TravelScheduleItem.Type {
            draft = RealmDraft.TravelSchedule
        } else if T.self is DayScheduleItem.Type {
            draft = RealmDraft.DaySchedule
        } else if T.self is SpecificScheduleItem.Type {
            draft = RealmDraft.SpecificSchedule
        } else if T.self is PlaceScheduleItem.Type {
            draft = RealmDraft.PlaceSchedule
        } else {
            draft = RealmDraft.ActivitySchedule
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
    
    func getTravelSchedule(travelScheduleUid: String) -> Observable<TravelScheduleItem> {
        let result = withRealm(RealmDraft.TravelSchedule, "getting travel schedule") { (realm) -> Observable<TravelScheduleItem> in
            let existData = realm.objects(TravelScheduleItem.self).filter("uid = %@", travelScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(travelScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
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
    
    func getPlaceSchedule(placeScheduleUid: String) -> Observable<PlaceScheduleItem> {
        let result = withRealm(RealmDraft.PlaceSchedule, "getting place schedule") { (realm) -> Observable<PlaceScheduleItem> in
            let existData = realm.objects(PlaceScheduleItem.self).filter("uid = %@", placeScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(placeScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func getActivitySchedule(activityScheduleUid: String) -> Observable<ActivityScheduleItem> {
        let result = withRealm(RealmDraft.ActivitySchedule, "getting activity schedule") { (realm) -> Observable<ActivityScheduleItem> in
            let existData = realm.objects(ActivityScheduleItem.self).filter("uid = %@", activityScheduleUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(ScheduleServiceError.itemNotExistOfId(activityScheduleUid))
            }
        }
        return result ?? .error(ScheduleServiceError.gettingFailed)
    }
    
    func travelSchedules() -> Observable<Results<TravelScheduleItem>> {
        let result = withRealm(RealmDraft.TravelSchedule, "getting all travel schedules") { (realm) -> Observable<Results<TravelScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.TravelSchedule)
            let travelSchedules = realm.objects(TravelScheduleItem.self)
            return Observable.collection(from: travelSchedules)
        }
        return result ?? .empty()
    }
    
    func daySchedules(ofTravelSchedule: ScheduleItem) -> Observable<Results<DayScheduleItem>> {
        let result = withRealm(RealmDraft.DaySchedule, "getting day schedules of") { (realm) -> Observable<Results<DayScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.DaySchedule)
            let daySchedules = realm.objects(DayScheduleItem.self).filter("parentUid = %@", ofTravelSchedule.uid)
            return Observable.collection(from: daySchedules)
        }
        return result ?? .empty()
    }
    
    func specificSchedules(ofDaySchedule: ScheduleItem) -> Observable<Results<SpecificScheduleItem>> {
        let result = withRealm(RealmDraft.SpecificSchedule, "getting specific schedules of") { (realm) -> Observable<Results<SpecificScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.SpecificSchedule)
            let specificSchedules = realm.objects(SpecificScheduleItem.self).filter("parentUid = %@", ofDaySchedule.uid)
            return Observable.collection(from: specificSchedules)
        }
        return result ?? .empty()
    }
    
    func placeSchedules(ofSpecificSchedule: ScheduleItem) -> Observable<Results<PlaceScheduleItem>> {
        let result = withRealm(RealmDraft.PlaceSchedule, "getting specific schedules of") { (realm) -> Observable<Results<PlaceScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.PlaceSchedule)
            let placeSchedules = realm.objects(PlaceScheduleItem.self).filter("parentUid = %@", ofSpecificSchedule.uid)
            return Observable.collection(from: placeSchedules)
        }
        return result ?? .empty()
    }
    
    func activitySchedules(ofPlaceSchedule: ScheduleItem) -> Observable<Results<ActivityScheduleItem>> {
        let result = withRealm(RealmDraft.ActivitySchedule, "getting specific schedules of") { (realm) -> Observable<Results<ActivityScheduleItem>> in
            let realm = withRealmDraft(RealmDraft.ActivitySchedule)
            let activitySchedules = realm.objects(ActivityScheduleItem.self).filter("parentUid = %@", ofPlaceSchedule.uid)
            return Observable.collection(from: activitySchedules)
        }
        return result ?? .empty()
    }
}
