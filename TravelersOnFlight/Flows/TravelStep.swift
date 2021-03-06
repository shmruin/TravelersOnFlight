//
//  TravelStep.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import RxFlow

enum TravelStep: Step {
    // Global
    case alert(String)
    case idle
    case travelFlowIsRequired
    
    // Travel
    case travelScreenIsRequired
    case travelIsSelected(withTravelData: TravelDataModel)
    
    // Day Schedule
    case dayScheduleScreenIsRequired(withTravel: TravelDataModel)
    case dayIsSelected(withDayData: DayDataModel)
    
    // Specific Schedule
    case speicificScheduleScreenIsRequired(withDay: DayDataModel)
}
