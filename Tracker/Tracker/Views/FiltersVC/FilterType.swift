//
//  FilterType.swift
//  Tracker
//
//  Created by Olya on 20.05.2025.
//

import Foundation

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: 
            return NSLocalizedString("allTrackers", comment: "ячейка все трекеры")
        case .today:
            return NSLocalizedString("trackersForToday", comment: "")
        case .completed:
            return NSLocalizedString("completedTrackers", comment: "")
        case .notCompleted:
            return NSLocalizedString("uncompletedTrackers", comment: "")
        }
    }
    
    var isDefault: Bool {
        return self == .all
    }
}
