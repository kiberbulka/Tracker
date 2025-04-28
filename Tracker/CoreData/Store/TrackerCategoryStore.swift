//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context = CoreDataManager.shared.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>

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
            print("❌ Failed to fetch categories: \(error)")
        }
    }


    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func category(at indexPath: IndexPath) -> TrackerCategory {
        let entity = fetchedResultsController.object(at: indexPath)
        return TrackerCategory(
            title: entity.title ?? "",
            trackers: []
            )
    }

    func addCategory(_ category: TrackerCategory) {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = category.title

        do {
            try context.save()
        } catch {
            print("❌ Failed to save new category: \(error)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}


