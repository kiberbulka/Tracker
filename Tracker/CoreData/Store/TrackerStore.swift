//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet = []
    private var deletedIndexes: IndexSet = []
    
    private let context = CoreDataManager.shared.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    override init() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        let entity = fetchedResultsController.object(at: indexPath)
        return Tracker(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            color: UIColor(hex: entity.color ?? "#FFFFFF") ?? .black,
            emoji: entity.emoji ?? "",
            schedule: Weekday.decodeSchedule(from: entity.schedule ?? "") ?? [],
            isHabit: entity.isHabit
        )
    }
    
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        
        var trackerCategoryCoreData: TrackerCategoryCoreData?
        
        do {
            let results = try context.fetch(request)
            if let existingCategory = results.first {
                trackerCategoryCoreData = existingCategory
            } else {
                trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData?.title = category.title
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Error fetching or creating category: \(error)")
        }
        trackerCoreData.trackerCategory = trackerCategoryCoreData
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        
        if let colorString = tracker.color.toHexString() {
            trackerCoreData.color = colorString
        } else {
            print("Ошибка преобразования цвета в строку")
            trackerCoreData.color = ""
        }
        
        trackerCoreData.isHabit = tracker.isHabit
        
        if let scheduleString = Weekday.encodeSchedule(tracker.schedule) {
            trackerCoreData.schedule = scheduleString
        } else {
            print("Ошибка кодирования расписания")
            trackerCoreData.schedule = ""
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    
    func fetchAllTrackers() -> [Tracker] {
        do {
            let results = try context.fetch(TrackerCoreData.fetchRequest())
            return results.map { entity in
                Tracker(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    color: UIColor(hex: entity.color ?? "#FFFFFF") ?? .black,
                    emoji: entity.emoji ?? "",
                    schedule: Weekday.decodeSchedule(from: entity.schedule ?? "") ?? [],
                    isHabit: entity.isHabit
                )
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.map { coreDataTracker in
            let scheduleString = coreDataTracker.schedule ?? ""
            let schedule: [Weekday] = Weekday.decodeSchedule(from: scheduleString) ?? []
            
            return Tracker(
                id: coreDataTracker.id ?? UUID(),
                name: coreDataTracker.name ?? "",
                color: UIColor(named: coreDataTracker.color ?? "") ?? .black,
                emoji: coreDataTracker.emoji ?? "",
                schedule: schedule,
                isHabit: coreDataTracker.isHabit
            )
        }
    }}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
            )
        )
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

