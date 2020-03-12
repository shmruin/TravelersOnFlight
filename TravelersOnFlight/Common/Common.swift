//
//  Common.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 08/02/2020.
//  Copyright © 2020 ruin09. All rights reserved.
//

import Foundation

class Common {
    static func increaseOneDateFeature(targetDate: Date, feature: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: feature, value: value, to: targetDate)
        
        return date!
    }
    
    static func convertDateFormaterToYYMMDD(_ date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yy.MM.dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
}
