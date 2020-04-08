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
}

// Dummy test Uid
var DummyTravelItem: TravelItem? = nil
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
    func createTravel(uid: String, countries: [String], cities: [String], stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "creating travel") { (realm) -> Observable<TravelItem> in
            let travel = TravelItem()
            travel.uid = uid
            travel.countries.append(objectsIn: countries)
            travel.cities.append(objectsIn: cities)
            travel.stDate = stDate
            travel.fnDate = fnDate
            travel.theme = eTheme.rawValue
            try realm.write {
                realm.add(travel)
            }
            return .just(travel)
        }
        
        return result ?? .error(TravelServiceError.creationFailed)
    }
    
    @discardableResult
    func deleteTravel(travel: TravelItem) -> Observable<Void> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "deleting travel", action: { (realm) -> Observable<Void> in
            try realm.write {
                realm.delete(travel, cascading: true)
            }
            return .empty()
        }) ?? .error(TravelServiceError.deletionFailed(travel))
        
        return result
    }
    
    func updateTravel(travel: TravelItem, stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "updating travel") { (realm) -> Observable<TravelItem> in
            try realm.write {
                travel.stDate = stDate
                travel.fnDate = fnDate
                travel.theme = eTheme.rawValue
            }
            return .just(travel)
        }
        return result ?? .error(TravelServiceError.updateFailed(travel))
    }
    
    func getTravel(travelUid: String) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting travel") { (realm) -> Observable<TravelItem> in
            let existData = realm.objects(TravelItem.self).filter("uid = %@", travelUid)
            if let data = existData.first {
                return .just(data)
            } else {
                return .error(TravelServiceError.itemNotExistOfId(travelUid))
            }
        }
        return result ?? .error(TravelServiceError.gettingFailed)
    }
    
    func travels() -> Observable<Results<TravelItem>> {
        let result = withRealm(RealmDraft.TravelersOnFlight, "getting all travels") { (realm) -> Observable<Results<TravelItem>> in
            let realm = withRealmDraft(RealmDraft.TravelersOnFlight)
            let travels = realm.objects(TravelItem.self)
            return Observable.collection(from: travels)
        }
        return result ?? .empty()
    }
}
