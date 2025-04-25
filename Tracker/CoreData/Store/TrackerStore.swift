//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    var trackers: [TrackerCoreData] = []
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
        super.init()
    }
    
    func addTracker(tracker: Tracker, categoryTitle: String) throws {
        let categoryStore = TrackerCategoryStore(context: context)
        categoryStore.isCategoryExists()
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", "Домашний уют")
        
        guard let category = try? context.fetch(request).first else {
            throw NSError(domain: "", code: 0)
        }
        
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.color = tracker.color.hexString
        trackerCD.schedule = Tracker.encodeSchedule(tracker.schedule)
        trackerCD.isHabit = tracker.isHabit
        trackerCD.trackerCategory = category
        
        try? context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        guard let trackersCD = try? context.fetch(request) else {
            return []
        }
        
        return trackersCD.compactMap { coreData in
            guard let id = coreData.id,
                  let name = coreData.name,
                  let emoji = coreData.emoji,
                  let colorString = coreData.color,
                  let category = coreData.trackerCategory else {
                return nil
            }
            let isHabit = coreData.isHabit
            

            guard let schedule = Tracker.decodeSchedule(from: coreData.schedule ?? "") else {
                return nil
            }
            
            guard let color = UIColor(hex: colorString) else {

                return nil
            }
            return Tracker(
                id: id,
                name: name,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isHabit: isHabit
            )
        }
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try? context.save()
        return newCategory
    }

}


