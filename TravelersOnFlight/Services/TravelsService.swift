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
    init() {
        // Dummy test data
        do {
            let realmTravel = withRealmDraft(RealmDraft.TravelersOnFlight)
            if realmTravel.objects(TravelItem.self).count == 0 {
                [(Date(), Date(), TravelTheme.getDefault())].forEach {
                    let res = self.createTravel(uid: Common.makeUid(), countries: ["Japan"], cities: ["Tokyo"], stDate: $0.0, fnDate: $0.1, eTheme: $0.2)
                    res.subscribe(onNext: { val in
                        DummyTravelItem = val
                        })
                        .disposed(by: disposeBag)
                }
            }
        } catch _ {
            print("#ERROR - while init TravelService")
        }
    }
    
    @discardableResult
    func createTravel(uid: String, countries: [String], cities: [String], stDate: Date?, fnDate: Date?, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating travel") { (realm) -> Observable<TravelItem> in
            let travel = TravelItem()
            travel.uid = uid
            travel.countries.append(objectsIn: countries)
            travel.cities.append(objectsIn: cities)
            travel.theme = eTheme.rawValue
            
            if let stDate = stDate, let fnDate = fnDate {
                (0...stDate.distanceIntOf(targetDate: fnDate)).forEach { (distance) in
                    SharedSubScheduleService.createDaySchedule(parent: travel, date: Common.increaseOneDateFeature(targetDate: stDate, feature: .day, value: distance))
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
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            return Observable.from(object: travel)
        } else {
            print("#ERROR - travel item is nil")
        }
        return .error(TravelServiceError.gettingFailed)
    }
    
    func travels() -> Observable<Results<TravelItem>> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting all travels") { (realm) -> Observable<Results<TravelItem>> in
            let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
            let travels = realm.objects(TravelItem.self)
            return Observable.collection(from: travels)
        }
        return result ?? .empty()
    }
    
    func bindTravelToSummary(travelUid: String,
                             summaryFunc: @escaping ((_ nDay: Int, _ nCountry: Int, _ nCity: Int) -> String),
                             label: UILabel,
                             disposeBag: DisposeBag) {
        let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
        if let travel = realm.objects(TravelItem.self).filter("uid = %@", travelUid).first {
            Observable.from(object: travel, emitInitialValue: true, properties: ["countries", "cities", "dayItems"])
            .map { travel -> String in
                return summaryFunc(travel.dayItems.count, travel.countries.count, travel.cities.count)
            }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        } else {
            print("#ERROR - travel item is nil")
        }
    }
}
