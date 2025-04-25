//
//  Tracker.swift
//  Tracker
//
//  Created by User on 25.03.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let isHabit: Bool
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Weekday], isHabit: Bool) {
           self.id = id
           self.name = name
           self.color = color
           self.emoji = emoji
           self.schedule = schedule
           self.isHabit = isHabit
       }
    
    init?(from coreData: TrackerCoreData) {
          guard
              let id = coreData.id,
              let name = coreData.name,
              let emoji = coreData.emoji,
              let color = coreData.color,
              let scheduleString = coreData.schedule,
              let schedule = Tracker.decodeSchedule(from: scheduleString)
          else {
              return nil
          }

          self.id = id
          self.name = name
          self.emoji = emoji
          self.color = UIColor(hex: color) ?? .systemBlue
          self.schedule = schedule
          self.isHabit = coreData.isHabit
      }
    
    static func encodeSchedule(_ schedule: [Weekday]) -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(schedule)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding schedule: \(error)")
            return nil
        }
    }
    
    static func decodeSchedule(from string: String) -> [Weekday]? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {return nil}
        do {
            let schedule = try decoder.decode([Weekday].self, from: data)
            return schedule
        } catch {
            print("Error decoding schedule: \(error)")
            return nil
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
