//
//  Weekdays.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    var numberValue: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let weekday = Weekday(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid weekday value: \(value)"
            )
        }
        self = weekday
    }
    
    static func encodeSchedule(_ schedule: [Weekday]) -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(schedule)
            let jsonString = String(data: data, encoding: .utf8)
            print("Закодированное расписание: \(jsonString ?? "Ошибка кодирования")") // Для отладки
            return jsonString
        } catch {
            print("Ошибка кодирования расписания: \(error)")
            return nil
        }
    }
    
    
    static func decodeSchedule(from string: String) -> [Weekday]? {
        let decoder = JSONDecoder()
        print("Декодирование расписания: \(string)") // Для отладки
        guard let data = string.data(using: .utf8) else {
            print("Ошибка преобразования строки в данные")
            return nil
        }
        do {
            let schedule = try decoder.decode([Weekday].self, from: data)
            print("Декодированное расписание: \(schedule)") // Для отладки
            return schedule
        } catch {
            print("Ошибка декодирования расписания: \(error)")
            return nil
        }
    }
}

