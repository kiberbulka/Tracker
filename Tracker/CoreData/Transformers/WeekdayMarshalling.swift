//
//  WeekdayMarshalling.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import Foundation

final class WeekdayMarshalling {
    
    func string(from weekdays: [Weekday]) -> String {
        weekdays.map { $0.rawValue}.joined(separator: ",")
    }
    
    func weekdays(from string: String) -> [Weekday] {
        string
            .split(separator: ",")
            .map {String($0)}
            .compactMap { Weekday(rawValue: $0)}
    }
}
