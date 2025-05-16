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
        switch self {
        case .Monday: return "Понедельник"
        case .Tuesday: return "Вторник"
        case .Wednesday: return "Среда"
        case .Thursday: return "Четверг"
        case .Friday: return "Пятница"
        case .Saturday: return "Суббота"
        case .Sunday: return "Воскресенье"
        }
    }

    var shortName: String {
        switch self {
        case .Monday: return "Пн"
        case .Tuesday: return "Вт"
        case .Wednesday: return "Ср"
        case .Thursday: return "Чт"
        case .Friday: return "Пт"
        case .Saturday: return "Сб"
        case .Sunday: return "Вс"
        }
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

    // Кастомный Decodable, чтобы обрабатывать русские значения
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        if let weekday = Weekday(rawValue: value) {
            self = weekday
            return
        }
        
        // Маппинг русских названий на enum
        let mapping: [String: Weekday] = [
            "Понедельник": .Monday,
            "Вторник": .Tuesday,
            "Среда": .Wednesday,
            "Четверг": .Thursday,
            "Пятница": .Friday,
            "Суббота": .Saturday,
            "Воскресенье": .Sunday
        ]
        
        if let mapped = mapping[value] {
            self = mapped
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid weekday value: \(value)"
            )
        }
    }

    // Encodable оставляем стандартным — будет сохраняться на английском
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    // Кодирование расписания в JSON строку
    static func encodeSchedule(_ schedule: [Weekday]) -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(schedule)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Ошибка кодирования расписания: \(error)")
            return nil
        }
    }

    // Декодирование JSON строки в массив Weekday
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
