//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)

}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerStore: NSObject {
   
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
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
            schedule: Weekday.decodeSchedule(from: entity.schedule ?? "") ?? [],
            isHabit: entity.isHabit
        )
    }
    
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        let trackerCoreData = TrackerCoreData(context: context)

        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        guard let trackerCategoryCoreData = try? context.fetch(request).first else { return }

        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.isHabit = tracker.isHabit

        // Кодирование расписания
        if let scheduleString = Weekday.encodeSchedule(tracker.schedule) {
            trackerCoreData.schedule = scheduleString
        } else {
            print("Ошибка кодирования расписания")
            trackerCoreData.schedule = "" // Или другое значение по умолчанию
        }

        trackerCoreData.trackerCategory = trackerCategoryCoreData
        trackerCategoryCoreData.addToTrackers(trackerCoreData)

        CoreDataManager.shared.saveContext()
    }

    
    func fetchTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            // Преобразуем Core Data объекты в обычные объекты
            let trackers = results.map { trackerCoreData in
                
                let scheduleString = trackerCoreData.schedule ?? ""
                print("Decoding schedule from Core Data: \(scheduleString)") // Для отладки

                // Если строка пустая, используем пустой массив
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
            return trackers
        } catch {
            print("Error fetching trackers: \(error)")
            return []
        }
    }


}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes,
              let deletedIndexes = deletedIndexes else {
            return
        }
        delegate?.didUpdate(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
            )
        )
        self.insertedIndexes = nil
        self.deletedIndexes = deletedIndexes
    }

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = indexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }

}




