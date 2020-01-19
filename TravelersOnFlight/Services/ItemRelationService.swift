//
//  ItemRelationService.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 03/09/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct ItemRelationService: ItemRelationServiceType {
    @discardableResult
    func createRelation(parentUid: String) -> Observable<Void> {
        let result = withRealm(RealmDraft.Relation, "creating") { (realm) -> Observable<Void> in
            let existData = realm.objects(ItemRelation.self).filter("parentUid = %@", parentUid)
            if let _ = existData.first {
                return .error(RelationServiceError.duplicatedCreation)
            } else {
                let relation = ItemRelation()
                relation.parentUid = parentUid
                try realm.write {
                    realm.add(relation)
                }
                return .empty()
            }
        }
        return result ?? .error(RelationServiceError.creationFailed)
    }
    
    @discardableResult
    func connectRelation<T>(element: T, parent: T, nextToSibling: T) -> Observable<T> where T : Relationable {
        let result = withRealm(RealmDraft.Relation, "connecting") { (realm) -> Observable<T> in
            let existData = realm.objects(ItemRelation.self).filter("parentUid = %@", element.parentUid)
            if let data = existData.first { // If already exist
                if let siblingIdx = data.siblingsUidList.index(of: nextToSibling.uid) {
                    let updatedList = data.siblingsUidList
                    updatedList.insert(element.uid, at: siblingIdx + 1)
                    try realm.write {
                        data.siblingsUidList = updatedList
                    }
                    return .just(element)
                } else {
                    return .error(RelationServiceError.siblingIdxNotExist)
                }
            } else { // If not exist before
                try realm.write {
                    let relation = ItemRelation()
                    relation.parentUid = parent.uid
                    let list = List<String>()
                    list.append(element.uid)
                    relation.siblingsUidList = list
                }
                return .just(element)
            }
        }
        return result ?? .error(RelationServiceError.connectionFailed)
    }
    
    @discardableResult
    func disconnectRelation<T>(element: T) -> Observable<Void> where T : Relationable {
        let result = withRealm(RealmDraft.Relation, "disconnecting") { (realm) -> Observable<Void> in
            let existData = realm.objects(ItemRelation.self).filter("parentUid = %@", element.parentUid)
            if let data = existData.first { // If already exist
                if let willDeleteIdx = data.siblingsUidList.index(of: element.uid) {
                    let deletedList = data.siblingsUidList
                    deletedList.remove(at: willDeleteIdx)
                    try realm.write {
                        data.siblingsUidList = deletedList
                    }
                    return .empty()
                } else {
                    return .error(RelationServiceError.targetElementNotExist)
                }
            } else {
                return .error(RelationServiceError.parentNotExist)
            }
        }
        return result ?? .error(RelationServiceError.disconnectionFailed)
    }
    
    @discardableResult
    func connectToLast<T>(element: T) -> Observable<T> where T : Relationable {
        let result = withRealm(RealmDraft.Relation, "connecting to last") { (realm) -> Observable<T> in
            let existData = realm.objects(ItemRelation.self).filter("parentUid = %@", element.parentUid)
            if let data = existData.first {
                let addedList = data.siblingsUidList
                addedList.append(element.uid)
                try realm.write {
                    data.siblingsUidList = addedList
                }
                return .just(element)
            } else {
//                return .error(RelationServiceError.parentNotExist)
                _ = createRelation(parentUid: element.parentUid)
                return .just(element)
            }
        }
        return result ?? .error(RelationServiceError.connectionToLastFailed)
    }
    
    @discardableResult
    func checkIfExist(parentUid: String) -> Bool {
        return withRealm(RealmDraft.Relation, "is id exist in relation") { (realm) -> Bool in
            let existData = realm.objects(ItemRelation.self).filter("parentUid = %@", parentUid)
            if let _ = existData.first {
                return true
            } else {
                return false
            }
        }!
    }
}
