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
    case Schedule = "schedule.realm"
    case Relation = "relation.realm"
}

enum TravelServiceError: Error {
    case creationFailed
    case updateFailed(TravelItem)
    case deletionFailed(TravelItem)
    case moveFailed(TravelItem)
}

enum ScheduleServiceError: Error {
    case creationFailed
    case updateFailed(ScheduleItem)
    case deletionFailed(ScheduleItem)
    case moveFailed(ScheduleItem)
}

enum RelationServiceError: Error {
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
        return try! Realm(configuration: config)
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
    func createTravel(stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem>
    
    @discardableResult
    func deleteTravel(travel: TravelItem) -> Observable<Void>
    
    @discardableResult
    func updateTravel(travel: TravelItem, stDate: Date, fnDate: Date, eTheme: TravelTheme) -> Observable<TravelItem>
    
    @discardableResult
    func moveTravel(travel: TravelItem, parent: TravelItem, nextToItem: TravelItem) -> Observable<TravelItem>
    
    func travels() -> Observable<Results<TravelItem>>
}

protocol ScheduleServiceType: RealmServiceType {
    @discardableResult
    func createTravelSchedule() -> Observable<TravelScheduleItem>
    
    @discardableResult
    func createDaySchedule(day: Date) -> Observable<DayScheduleItem>
    
    @discardableResult
    func createLocationSchedule(country: String, city: String) -> Observable<LocationScheduleItem>
    
    @discardableResult
    func createSpecificSchedule(time: Date) -> Observable<SpecificScheduleItem>
    
    @discardableResult
    func createPlaceSchedule(placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem>
    
    @discardableResult
    func createActivitySchedule(activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem>
    
    @discardableResult
    func updateDaySchedule(daySchedule: DayScheduleItem, day: Date) -> Observable<DayScheduleItem>
    
    @discardableResult
    func updateLocationSchedule(locationSchedule: LocationScheduleItem, country: String, city: String) -> Observable<LocationScheduleItem>
    
    @discardableResult
    func updateSpecificSchedule(specificSchedule: SpecificScheduleItem, time: Date) -> Observable<SpecificScheduleItem>
    
    @discardableResult
    func updatePlaceSchedule(placeSchedule: PlaceScheduleItem, placeCategory: PlaceCategoryRepository, placeName: String) -> Observable<PlaceScheduleItem>
    
    @discardableResult
    func updateActivitySchedule(activitySchedule: ActivityScheduleItem, activityCategory: ActivityCategoryRepository, activityName: String) -> Observable<ActivityScheduleItem>
    
    @discardableResult
    func deleteSchedule(schedule: ScheduleItem) -> Observable<Void>
    
    @discardableResult
    func moveSchedule(schedule: ScheduleItem, parent: ScheduleItem, nextToItem: ScheduleItem) -> Observable<ScheduleItem>
    
    func travelSchedules() -> Observable<Results<TravelScheduleItem>>
    
    func daySchedules(ofTravelSchedule: ScheduleItem) -> Observable<Results<DayScheduleItem>>
    
    func locationSchedules(ofDaySchedule: ScheduleItem) -> Observable<Results<LocationScheduleItem>>
    
    func specificSchedules(ofLocationSchedule: ScheduleItem) -> Observable<Results<SpecificScheduleItem>>
    
    func placeSchedules(ofSpecificSchedule: ScheduleItem) -> Observable<Results<PlaceScheduleItem>>
    
    func activitySchedules(ofPlaceSchedule: ScheduleItem) -> Observable<Results<ActivityScheduleItem>>
}

protocol ItemRelationServiceType: RealmServiceType {
    @discardableResult
    func connectRelation<T: Relationable>(element: T, parent: T, nextToSibling: T) -> Observable<T>
    
    @discardableResult
    func disconnectRelation<T: Relationable>(element: T) -> Observable<Void>
    
    @discardableResult
    func connectToLast<T: Relationable>(element: T) -> Observable<T>
}
