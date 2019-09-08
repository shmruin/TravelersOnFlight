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

class ScheduleService {
    
}

//
//class ScheduleService: ScheduleServiceType {
//
//    init() {
//        // Dummy data
//        do {
//            let realm = withRealmDraft(RealmDraft.Schedule)
//            if realm.objects(TravelItem.self).count == 0 {
//                // Travel schedule
//
//                // Day schedule
//
//                // Location schedule
//
//                // Specific schedule
//
//                // Place schedule
//
//                // Activity schedule
//
//            }
//        } catch _ {
//        }
//    }
//}
