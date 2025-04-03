//
//  Weekdays.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday:"Пн"
        case .tuesday :"Вт"
        case .wednesday : "Ср"
        case .thursday :"Чт"
        case .friday : "Пт"
        case .saturday : "Сб"
        case .sunday : "Вс"
        }
    }
}
