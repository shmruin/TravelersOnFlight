//
//  SchedulePageContentViewModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/10/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import RxFlow
import RxSwift
import RxSwiftExt
import RxDataSources
import RxCocoa
import NSObject_Rx

class SchedulePageContentViewModel: ServicesViewModel, Stepper, HasDisposeBag {
    typealias Services = HasScheduleService

    let steps = PublishRelay<Step>()
    var services: Services!
    
    let thisDay: Int?
    
    // Collections

    init(day: Int) {
        self.thisDay = day
    }
    
}
