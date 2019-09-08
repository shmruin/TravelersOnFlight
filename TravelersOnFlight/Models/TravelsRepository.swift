//
//  TravelsRepository.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

//import Foundation
//
//struct TravelsRepository {
//    static let repoTravels = [
//        Travel(id: 10001,
//               stDate: Date(),
//               fnDate: Date(),
//               theme: TravelTheme.Unexpected,
//               travelScheduleId: 20001)
//    ]
//
//    static let repoTravelSchedules = [
//        TravelSchedule(id: 20001,
//                       parentId: 10001,
//                       daySchedulesId: [30001])
//    ]
//
//    static let repoDaySchedules = [
//        DaySchedule(id: 30001,
//                    parentId: 20001,
//                    date: Date(),
//                    locationSchedulesId: [40001])
//    ]
//
//    static let repoLocationSchedules = [
//        LocationSchedule(id: 40001,
//                     parentId: 30001,
//                     country: "Japan",
//                     city: "Tokyo",
//                     specificSchedulesId: [50001])
//    ]
//
//    static let repoSpecificSchedules = [
//        SpecificSchedule(id: 50001,
//                         parentId: 40001,
//                         time: Date(),
//                         placesId: [60001, 60002])
//    ]
//
//    static let repoPlaceSchedules = [
//        Place(id: 60001,
//              parentId: 50001,
//              placeCategory: PlaceCategoryRepository.Airport,
//              placeName: "인천공항",
//              activitiesId: [70001, 70002]),
//        Place(id: 60002,
//              parentId: 50001,
//              placeCategory: PlaceCategoryRepository.Hotel,
//              placeName: "호텔",
//              activitiesId: [70003])
//    ]
//
//    static let repoActivitySchedules = [
//        Activicy(id: 70001,
//                 parentId: 60001,
//                 activityCategory: ActivityCategoryRepository.SightSeeing,
//                 activityName: "공항 구경하기"),
//        Activicy(id: 70002,
//                 parentId: 60001,
//                 activityCategory: ActivityCategoryRepository.Moving,
//                 activityName: "비행기 타고 이동"),
//        Activicy(id: 70003,
//                 parentId: 60002,
//                 activityCategory: ActivityCategoryRepository.Relaxing,
//                 activityName: "호텔에서 휴식")
//    ]
//}
