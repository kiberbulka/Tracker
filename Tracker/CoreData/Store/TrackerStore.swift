//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )

}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerStore: NSObject {
   
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    private let context = CoreDataManager.shared.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    override init(){
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
                   print("❌ Failed to fetch trackers: \(error)")
               }
    }
    
    func numbersOfSection() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        let entity = fetchedResultsController.object(at: indexPath)
        return Tracker(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            color: UIColor(hex: entity.color ?? "#FFFFFF") ?? .black,
            emoji: entity.emoji ?? "",
            schedule: Tracker.decodeSchedule(from: entity.schedule ?? "") ?? [],
            isHabit: entity.isHabit
        )
    }
    
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryCoreData = categories.first {
                let trackerEntity = TrackerCoreData(context: context)
                trackerEntity.id = tracker.id
                trackerEntity.name = tracker.name
                trackerEntity.color = tracker.color.hexString
                trackerEntity.emoji = tracker.emoji
                trackerEntity.schedule = Tracker.encodeSchedule(tracker.schedule)
                trackerEntity.isHabit = tracker.isHabit
                trackerEntity.trackerCategory = categoryCoreData

                try context.save()
            }
        } catch {
            print("❌ Ошибка при сохранении трекера: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}


