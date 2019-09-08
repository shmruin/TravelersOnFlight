//
//  ItemRelation.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 03/09/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RealmSwift
import RxDataSources


// Adjacent list for each sibling list - 1:N Relation

class ItemRelation: Object {
    @objc dynamic var parentUid: String = UUID().uuidString
    var siblingsUidList: List<String> = List<String>()
    
    override class func primaryKey() -> String? {
        return "parentUid"
    }
}

extension ItemRelation: IdentifiableType {
    var identity: String {
        return self.isInvalidated ? "" : parentUid
    }
}
