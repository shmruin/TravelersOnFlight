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

struct TravelService: TravelServiceType {
    
    let itemRealtionService = ItemRelationService()
    
    init() {
        // Dummy data
        do {
            let realm = withRealmDraft(RealmDraft.Travel)
            if realm.objects(TravelItem.self).count == 0 {
                [(Date(), Date(), TravelTheme.Unexpected)].forEach {
                    self.createTravel(stDate: $0.0, fnDate: $0.1, eTheme: $0.2)
                }
            }
        } catch _ {
        }
    }
    
    @discardableResult
    func createTravel(stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.Travel, "creating") { (realm) -> Observable<TravelItem> in
            let travel = TravelItem()
            travel.stDate = stDate
            travel.fnDate = fnDate
            travel.theme = eTheme.rawValue
            try realm.write {
                realm.add(travel)
            }
            return .just(travel)
            }?
            .do(onNext: { resTravel in
                return self.itemRealtionService.connectToLast(element: resTravel)
            })
        
        return result ?? .error(TravelServiceError.creationFailed)
    }
    
    @discardableResult
    func deleteTravel(travel: TravelItem) -> Observable<Void> {
        let result = itemRealtionService.disconnectRelation(element: travel)
                .flatMapLatest { _ in
                    return self.withRealm(RealmDraft.Travel, "deleting", action: { (realm) -> Observable<Void> in
                        try realm.write {
                            realm.delete(travel)
                        }
                        return .empty()
                    }) ?? .error(TravelServiceError.deletionFailed(travel))
                }
                .catchError { (error) -> Observable<Void> in
                    return .error(TravelServiceError.deletionFailed(travel))
                }
        
        return result
    }
    
    func updateTravel(travel: TravelItem, stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem> {
        let result = withRealm(RealmDraft.Travel, "updating") { (realm) -> Observable<TravelItem> in
            try realm.write {
                travel.stDate = stDate
                travel.fnDate = fnDate
                travel.theme = eTheme.rawValue
            }
            return .just(travel)
        }
        return result ?? .error(TravelServiceError.updateFailed(travel))
    }
    
    func moveTravel(travel: TravelItem, parent: TravelItem, nextToItem: TravelItem) -> Observable<TravelItem> {
        let result = itemRealtionService.disconnectRelation(element: travel)
                .flatMapLatest { _ in
                    return self.itemRealtionService.connectRelation(element: travel, parent: parent, nextToSibling: nextToItem)
                }
                .catchError { (error) -> Observable<TravelItem> in
                    return .error(TravelServiceError.moveFailed(travel))
                }
        
        return result
    }
    
    func travels() -> Observable<Results<TravelItem>> {
        let result = withRealm(RealmDraft.Travel, "getting travels") { (realm) -> Observable<Results<TravelItem>> in
            let realm = withRealmDraft(RealmDraft.Travel)
            let travels = realm.objects(TravelItem.self)
            return Observable.collection(from: travels)
        }
        return result ?? .empty()
    }
}
