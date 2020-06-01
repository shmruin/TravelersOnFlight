//
//  TravelsService.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm


protocol HasTravelService {
    var travelService: TravelService { get }
    var scheduleService: ScheduleService { get }
}

// Dummy test Uid
var DummyTravelItem: TravelItem? = nil
var SharedSubScheduleService = ScheduleService()
private let disposeBag = DisposeBag()

struct TravelService: TravelServiceType {
    
    init() { }
    
    @discardableResult
    func createTravel(uid: String, country: String, city: String, stDate: Date?, fnDate: Date?, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating travel") { (realm) -> Observable<TravelItem> in
            let travel = TravelItem()
            travel.uid = uid
            travel.theme = eTheme.rawValue
            
            if let stDate = stDate, let fnDate = fnDate {
                (0...stDate.distanceIntOf(targetDate: fnDate)).forEach { (distance) in
                    if distance == 0 { // First day scheudle have to create the initial specific schedule in it
                        SharedSubScheduleService
                            .createDaySchedule(parent: travel, date: Common.increaseOneDateFeature(targetDate: stDate, feature: .day, value: distance))
                            .flatMapLatest { dayItem in
                                return SharedSubScheduleService.createSpecificSchedule(parent: dayItem,
                                                                                       country: country,
                                                                                       city: city,
                                                                                       area: "",
                                                                                       stTime: Common.setDateAtHM(targetDate: dayItem.date, hour: 7, minutes: 0),
                                                                                       fnTime: Common.setDateAtHM(targetDate: dayItem.date, hour: 8, minutes: 0),
                                                                                       placeCategory: PlaceCategoryRepository.Select,
                                                                                       placeName: "",
                                                                                       activityCategory: ActivityCategoryRepository.Select,
                                                                                       activityName: "")
                            }
                    } else {
                        SharedSubScheduleService.createDaySchedule(parent: travel, date: Common.increaseOneDateFeature(targetDate: stDate, feature: .day, value: distance))
                    }
                }
            }
            
            try realm.write {
                realm.add(travel)
            }
            
            return .just(travel)
        }
        
        return result ?? .error(TravelServiceError.creationFailed)
    }
    
    @discardableResult
    func deleteTravel(travel: TravelItem) -> Observable<String> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "deleting travel", action: { (realm) -> Observable<String> in
            let deletedUid = travel.uid
            
            try realm.write {
                realm.delete(travel, cascading: true)
            }
            return .just(deletedUid)
        }) ?? .error(TravelServiceError.deletionFailed(travel))
        
        return result
    }
    
    func updateTravel(travel: TravelItem, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "updating travel") { (realm) -> Observable<TravelItem> in
            try realm.write {
                travel.theme = eTheme.rawValue
            }
            return .just(travel)
        }
        return result ?? .error(TravelServiceError.updateFailed(travel))
    }
    
    func getTravel(travelUid: String) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting a travel") { (realm) -> Observable<TravelItem> in
            let existData = realm.objects(TravelItem.self).filter("uid = %@", travelUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(TravelServiceError.itemNotExistOfId(travelUid))
            }
        }
        return result ?? .error(TravelServiceError.gettingFailed)
    }
    
    func getTravelFromObject(travelUid: String) -> Observable<TravelItem> {
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            return Observable.from(object: travel)
        } else {
            print("#ERROR - travel item is nil")
        }
        return .error(TravelServiceError.gettingFailed)
    }
    
    func getCountriesFromObject(travelUid: String) -> Observable<[String]> {
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            return Observable.from(object: travel)
                            .map { travelItem in
                                return Array(travelItem.dayItems).reduce(into: []) { (res, dayScheduleItem) in
                                    res += Array(dayScheduleItem.specificItems).map { $0.country }
                                    _ = Array(Set(res))
                                }
                            }
        } else {
            print("#ERROR - travel item is nil")
        }
        return .error(TravelServiceError.gettingFailed)
    }
    
    func getCitiesFromObject(travelUid: String) -> Observable<[String]> {
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            return Observable.from(object: travel)
                            .map { travelItem in
                                return Array(travelItem.dayItems).reduce(into: []) { (res, dayScheduleItem) in
                                    res += Array(dayScheduleItem.specificItems).map { $0.city }
                                    _ = Array(Set(res))
                                }
                            }
        } else {
            print("#ERROR - travel item is nil")
        }
        return .error(TravelServiceError.gettingFailed)
    }
    
    func travels() -> Observable<Results<TravelItem>> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting all travels") { (realm) -> Observable<Results<TravelItem>> in
            let travels = realm.objects(TravelItem.self)
            return Observable.collection(from: travels)
        }
        return result ?? .empty()
    }
    
    func getDaysOfTravel(travelUid: String) -> Observable<Int> {
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            return Observable
                        .from(object: travel)
                        .map { res in res.dayItems.count }
        } else {
            print("#ERROR - travel item is nil")
        }
        return .error(TravelServiceError.gettingFailed)
    }
}
