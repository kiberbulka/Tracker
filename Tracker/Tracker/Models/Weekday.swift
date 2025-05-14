//
//  Weekdays.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var shortName: String {
        return NSLocalizedString("\(self.rawValue)_short", comment: "")
    }
    var numberValue: Int {
        switch self {
        case .Monday: return 1
        case .Tuesday: return 2
        case .Wednesday: return 3
        case .Thursday: return 4
        case .Friday: return 5
        case .Saturday: return 6
        case .Sunday: return 7
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
            return jsonString
        } catch {
            print("Ошибка кодирования расписания: \(error)")
            return nil
        }
    }
    
    
    static func decodeSchedule(from string: String) -> [Weekday]? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            print("Ошибка преобразования строки в данные")
            return nil
        }
        do {
            let schedule = try decoder.decode([Weekday].self, from: data)
            return schedule
        } catch {
            print("Ошибка декодирования расписания: \(error)")
            return nil
        }
    }
}

