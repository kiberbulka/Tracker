//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
   
    weak var delegate: TrackerStoreDelegate?
    
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
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.color = tracker.color.hexString
        entity.emoji = tracker.emoji
        entity.schedule = Tracker.encodeSchedule(tracker.schedule)
        entity.isHabit = tracker.isHabit
        
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to save new tracker: \(error)")
        }
    }
    
    private func fetchCategoryById() -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
     //   fetchRequest.predicate = NSPredicate(format: "id == %@", id as! any CVarArg as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("❌ Failed to fetch category by id: \(error)")
            return nil
        }
    }
    
  
  

}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}


