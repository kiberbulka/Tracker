//
//  StatisticsService.swift
//  Tracker
//
//  Created by Olya on 17.05.2025.
//
import CoreData
import Foundation

struct StatisticsData {
    let longestStreak: Int
    let perfectDays: Int
    let completedCount: Int
    let averagePerDay: Int
}

final class StatisticsService {
    
    // MARK: - Private Properties
    
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    private let calendar = Calendar.current
    
    // MARK: - Initializers
    
    init(trackerStore: TrackerStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }
    
    convenience init() {
        self.init(trackerStore: TrackerStore(), trackerRecordStore: TrackerRecordStore())
    }
    
    // MARK: - Public Methods
    
    func fetchStatistics() -> StatisticsData {
        let trackers = trackerStore.fetchTrackers()
        let trackerIDs = Set(trackers.map { $0.id })
        
        let records = trackerRecordStore.fetch()
        
        let groupedByDate = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        
        let perfectDays = groupedByDate.filter { (_, records) in
            let completedIDs = Set(records.map { $0.trackerID })
            return completedIDs == trackerIDs && !trackerIDs.isEmpty
        }.count
        
        let completedCount = records.count
        
        let uniqueDaysCount = groupedByDate.keys.count
        let averagePerDay = uniqueDaysCount == 0 ? 0 : Int(round(Double(completedCount) / Double(uniqueDaysCount)))
        
        var longestStreak = 0
        let groupedByTracker = Dictionary(grouping: records) { $0.trackerID }
        
        for (_, trackerRecords) in groupedByTracker {
            let sortedDates = trackerRecords
                .map { calendar.startOfDay(for: $0.date) }
                .sorted()
            
            var currentStreak = 1
            var maxStreak = 1
            
            for i in 1..<sortedDates.count {
                let previousDate = sortedDates[i - 1]
                let currentDate = sortedDates[i]
                
                if calendar.date(byAdding: .day, value: 1, to: previousDate) == currentDate {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else if previousDate != currentDate {
                    currentStreak = 1
                }
            }
            longestStreak = max(longestStreak, maxStreak)
        }
        
        return StatisticsData(
            longestStreak: longestStreak,
            perfectDays: perfectDays,
            completedCount: completedCount,
            averagePerDay: averagePerDay
        )
    }
}



