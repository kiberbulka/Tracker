//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    var trackers: [TrackerCoreData] = []
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(){
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func fetchAllTrackers(){
        let request = TrackerCoreData.fetchRequest()
        if let trackers = try? context.fetch(request) {
            self.trackers = trackers
        }
    }
    
    func addTracker(tracker: Tracker, category: String) {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.id = tracker.id
        trackerCD.emoji = tracker.emoji
        trackerCD.name = tracker.name
        trackerCD.colorHex = UIColorMarshalling().hexString(from: tracker.color)
        trackerCD.isHabit = tracker.type == .habit
        trackerCD.schedule = tracker.schedule
    }
    
}


