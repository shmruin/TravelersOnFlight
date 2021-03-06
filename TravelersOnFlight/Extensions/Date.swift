//
//  Date.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 27/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation


extension Date {
    
    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }
    
    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }
    
    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }
    
    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }
    
    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }
    
    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }
    
    var formatMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    func formatString(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func distanceIntOf(targetDate: Date) -> Int {
        return abs(Calendar.current.dateComponents([.day], from: self, to: targetDate).day!)
    }
    
    func compareTo(date: Date, toGranularity: Calendar.Component) -> ComparisonResult  {
        let cal = Calendar.current
        return cal.compare(self, to: date, toGranularity: toGranularity)
    }
}
