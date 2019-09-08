//
//  CategoryRepository.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//


enum PlaceCategoryRepository: String, Category {
    case Airport = "공항"
    case Hotel = "호텔"
    case LocalMarket = "지역 시장"
    case Spa = "온천"
    case SubwayStation = "지하철 역"
}

enum ActivityCategoryRepository: String, Category {
    case Shopping = "쇼핑하기"
    case SightSeeing = "구경"
    case Eating = "식사"
    case Relaxing = "휴식"
    case Moving = "이동"
}
