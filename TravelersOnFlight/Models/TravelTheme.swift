//
//  TravelTheme.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 27/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//


enum TravelTheme: String, CaseIterable {
    case AlwaysGood = "AlwaysGood"
    case LookingForHappiness = "Looking For Happiness"
    case Vacation = "Vacation"
    case Unexpected = "Unexpected"
    case JustWonderful = "Just Wonderful"
    case Lonely = "Lonely"
    case WithFriends = "With Friends"
    case WithFamily = "With Family"
    case DreamsComeTrue = "Dreams Come True"
    
    static func getDefault() -> TravelTheme {
        return .Unexpected
    }
}
