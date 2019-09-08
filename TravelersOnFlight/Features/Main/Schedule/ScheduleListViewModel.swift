////
////  ScheduleListViewModel.swift
////  TravelersOnFlight
////
////  Created by ruin09 on 30/08/2019.
////  Copyright © 2019 ruin09. All rights reserved.
////
//
//import RxFlow
//import RxSwift
//import RxCocoa
//
//class ScheduleListViewModel: ServicesViewModel, Stepper {
//    
//    typealias Services = HasScheduleService
//    let steps = PublishRelay<Step>()
//    
//    private(set) var rootSchedule: ScheduleViewModel?
//    public let travelId: Int
//    
//    var services: Services! {
//        didSet {
//            let travelSchedule = self.services.scheduleService.schedule(forTravelId: travelId)
//            self.rootSchedule = ScheduleViewModel(travelSchedule: travelSchedule)
//        }
//    }
//    
//    init(withTravelId id: Int) {
//        self.travelId = id
//    }
//    
//    // TODO: Schedule actions
//}
