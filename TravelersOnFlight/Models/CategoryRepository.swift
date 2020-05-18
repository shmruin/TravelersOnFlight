//
//  CategoryRepository.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

enum PlaceCategoryRepository: String, Category, CaseIterable {
    case Beach = "🏖 Beach"
    case City = "🏙 City"
    case HistoricalSite = "🏛 Historical Site"
    case Church = "⛪️ Church"
    case HotPlace = "🗼 Hot Place"
    case NightSightseeing = "🌌 Night Sightseeing"
    case LocalMarket = "🛒 Local Market"
    case DepartmentStore = "🏬 Department Store"
    case ConvenienceStore = "🏪 Convenience Store"
    case DrinkBar = "🍺 Drink Bar"
    case Sunrise = "🌅 Sunrise"
    case Sunset = "🌄 Sunset"
    case Spa = "♨️ Spa"
    case Cafe = "☕️ Cafe"
    case Ferry = "⛴ Ferry"
    case Sailboat = "⛵️ Sailboat"
    case Fireworks = "🎆 Fireworks"
    case AmusementPark = "🎡 Amusement Park"
    case NationalPark = "🏞 National Park"
    case Mountain = "⛰ Mountain"
    case Camping = "🏕 Camping"
    case Hospital = "🏥 Hospital"
    case Hotel = "🏨 Hotel"
    case Airport = "✈️ Airport"
    case Automobile = "🚗 Automobile"
    case Port = "⚓️ Port"
    case Taxi = "🚖 Taxi"
    case SubwayStation = "🚉 Subway Station"
    case BusStation = "🚏 Bus Stop"
    case Custom = "😀 My own place!"
    case Select = "❓ Select the place"
    case None = "❗️ None"
    
    static var userCases: [PlaceCategoryRepository] {
        return Self.allCases.filter { $0 != .Select && $0 != .None  }
    }
}

enum ActivityCategoryRepository: String, Category, CaseIterable {
    case Shopping = "🛍 Shopping"
    case SightSeeing = "👀 Sightseeing"
    case BikeRiding = "🚴‍♀️ Bike riding"
    case Refresh = "⏳ Just a refresh"
    case Eating = "🍽 Eating"
    case Snack = "🍩 Snack"
    case VideoGame = "🕹 Video games"
    case Tour = "🎒Simple tour"
    case GroupTour = "👥 Group tour"
    case Enjoy = "😍 Enjoy"
    case FunnyThings = "🎳 Funny things"
    case Movie = "📽 Watch a movie"
    case Concert = "🎫 Go to a concert"
    case Relax = "😴 Relax"
    case Party = "🎉 Party"
    case Shower = "🚿 Shower"
    case Moving = "🦶 Moving"
    case Custom = "😀 My own activity!"
    case Select = "❓ Select the activity"
    case None = "❗️ None"
    
    static var userCases: [ActivityCategoryRepository] {
        return Self.allCases.filter { $0 != .Select && $0 != .None  }
    }
}
