//
//  CategoryRepository.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//


enum PlaceCategoryRepository: String, Category, CaseIterable {
    case Airport = "Airport"
    case Hotel = "Hotel"
    case LocalMarket = "Local Market"
    case Spa = "Spa"
    case SubwayStation = "Subway Station"
    case Select = "Select the place"
    case Error = "Error"
}

enum ActivityCategoryRepository: String, Category, CaseIterable {
    case Shopping = "Shopping"
    case SightSeeing = "SightSeeing"
    case Eating = "Eating"
    case Relaxing = "Relaxing"
    case Moving = "Moving"
    case Select = "Select the activity"
    case Error = "Error"
}
