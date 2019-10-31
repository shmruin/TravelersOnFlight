//
//  ServiceType.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 02/09/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

enum RealmDraft: String {
    case Travel = "travel.realm"
    case TravelSchedule = "travelSchedule.realm"
    case DaySchedule = "daySchedule.realm"
    case SpecificSchedule = "specificSchedule.realm"
    case PlaceSchedule = "placeSchedule.realm"
    case ActivitySchedule = "activitySchedule.realm"
    case Relation = "relation.realm"
}

enum CommonRealmError: Error {
    case duplicatedUniqueValue(String)
}

enum TravelServiceError: Error {
    case itemNotExistOfId(String)
    case gettingFailed
    case creationFailed
    case updateFailed(TravelItem)
    case deletionFailed(TravelItem)
    case moveFailed(TravelItem)
}

enum ScheduleServiceError: Error {
    case itemNotExistOfId(String)
    case itemNotExistOfCondition
    case gettingFailed
    case creationFailed(ScheduleItem.Type)
    case updateFailed(ScheduleItem)
    case deletionFailed(ScheduleItem)
    case moveFailed(ScheduleItem)
}

enum RelationServiceError: Error {
    case duplicatedCreation
    case creationFailed
    case connectionFailed
    case disconnectionFailed
    case connectionToLastFailed
    case siblingIdxNotExist
    case parentNotExist
    case targetElementNotExist
}

protocol RealmServiceType {
    
}

extension RealmServiceType {
    func withRealmDraft(_ draft: RealmDraft) -> Realm {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let url = documentDirectory.appendingPathComponent(draft.rawValue)
        var config = Realm.Configuration()
        config.fileURL = url
        let realm = try! Realm(configuration: config)
        // To unlock encrypt
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        // Disable file protection for this directory
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
                                               ofItemAtPath: folderPath)
        return realm
    }
    
    func withRealm<T>(_ draft: RealmDraft,_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = withRealmDraft(draft)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
}

protocol TravelServiceType: RealmServiceType {
    @discardableResult
    func createTravel(uid: String, countries: [String], cities: [String], stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem>
    
    @discardableResult
    func deleteTravel(travel: TravelItem) -> Observable<Void>
    
    @discardableResult
    func updateTravel(travel: TravelItem, stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem>
    
    @discardableResult
    func moveTravel(travel: TravelItem, parent: TravelItem, nextToItem: TravelItem) -> Observable<TravelItem>
    
    func getTravel(travelUid: String) -> Observable<TravelItem>
    
    func travels() -> Observable<Results<TravelItem>>
}

protocol ScheduleServiceType: RealmServiceType {
    @discardableResult
    func createTravelSchedule(parent: TravelItem) -> Observable<TravelScheduleItem>

    @discardableResult
    func createDaySchedule(parent: TravelScheduleItem, day: Date) -> Observable<DayScheduleItem>

    @discardableResult
    func createSpecificSchedule(parent: DayScheduleItem, country: String, city: String, stTime: Date, fnTime: Date) -> Observable<SpecificScheduleItem>

    @discardableResult
    func createPlaceSchedule(parent: SpecificScheduleItem, placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem>

    @discardableResult
    func createActivitySchedule(parent: PlaceScheduleItem, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem>

    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, day: Date) -> Observable<DayScheduleItem>

    @discardableResult
    func updateSpecificSchedule(specificSchedule: SpecificScheduleItem, country: String, city: String, stTime: Date, fnTime: Date) -> Observable<SpecificScheduleItem>

    @discardableResult
    func updatePlaceSchedule(placeSchedule: PlaceScheduleItem, placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem>

    @discardableResult
    func updateActivitySchedule(activitySchedule: ActivityScheduleItem, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem>

    @discardableResult
    func deleteSchedule<T>(schedule: ScheduleItem, scheduleType: T.Type) -> Observable<Void>

//    @discardableResult
//    func moveSchedule<T>(schedule: ScheduleItem, parent: ScheduleItem, nextToItem: ScheduleItem, scheduleType: T.Type) -> Observable<ScheduleItem>
    
    func getTravelSchedule(travelScheduleUid: String) -> Observable<TravelScheduleItem>
    
    func getDaySchedule(dayScheduleUid: String) -> Observable<DayScheduleItem>
    
    func getDaySchedule(ofNthDay: Int) -> Observable<DayScheduleItem>
    
    func getSpecificSchedule(specificScheduleUid: String) -> Observable<SpecificScheduleItem>
    
    func getPlaceSchedule(placeScheduleUid: String) -> Observable<PlaceScheduleItem>
    
    func getActivitySchedule(activityScheduleUid: String) -> Observable<ActivityScheduleItem>
    
    func travelSchedules() -> Observable<Results<TravelScheduleItem>>

    func daySchedules(ofTravelSchedule: ScheduleItem) -> Observable<Results<DayScheduleItem>>

    func specificSchedules(ofDaySchedule: ScheduleItem) -> Observable<Results<SpecificScheduleItem>>

    func placeSchedules(ofSpecificSchedule: ScheduleItem) -> Observable<Results<PlaceScheduleItem>>

    func activitySchedules(ofPlaceSchedule: ScheduleItem) -> Observable<Results<ActivityScheduleItem>>
}

protocol ItemRelationServiceType: RealmServiceType {
    @discardableResult
    func createRelation(parentUid: String) -> Observable<Void>
    
    @discardableResult
    func connectRelation<T: Relationable>(element: T, parent: T, nextToSibling: T) -> Observable<T>
    
    @discardableResult
    func disconnectRelation<T: Relationable>(element: T) -> Observable<Void>
    
    @discardableResult
    func connectToLast<T: Relationable>(element: T) -> Observable<T>
}
