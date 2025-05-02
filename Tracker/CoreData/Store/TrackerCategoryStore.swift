//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories(_ update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context = CoreDataManager.shared.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    var numberOfSection: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    override init() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
            print("Failed to fetch categories: \(error)")
        }
    }
    
    func create(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = []
        CoreDataManager.shared.saveContext()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            
            return trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    
                    let scheduleString = trackerCoreData.schedule ?? ""
                    let schedule = scheduleString.isEmpty ? [] : Weekday.decodeSchedule(from: scheduleString) ?? []
                    
                    return Tracker(
                        id: trackerCoreData.id ?? UUID(),
                        name: trackerCoreData.name ?? "",
                        color: UIColor(hex: trackerCoreData.color ?? "") ?? .colorSection1,
                        emoji: trackerCoreData.emoji ?? "",
                        schedule: schedule,
                        isHabit: trackerCoreData.isHabit
                    )
                }
                return TrackerCategory(title: title, trackers: trackerObjects)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
}
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes else { return }
        delegate?.didUpdateCategories(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes
            )
        )
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.row)
                }
            case .insert:
                if let newIndexPath = newIndexPath {
                    insertedIndexes?.insert(newIndexPath.row)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.row)
                }
            default:
                break
            }
        }
}




