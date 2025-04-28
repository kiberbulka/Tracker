//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: TrackerRecordStoreDelegate?

    private let context = CoreDataManager.shared.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>

    override init() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

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
            print("❌ Failed to fetch tracker records: \(error)")
        }
    }

    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func record(at indexPath: IndexPath) -> TrackerRecord {
        let entity = fetchedResultsController.object(at: indexPath)
        return TrackerRecord(
            trackerID: entity.trackerID ?? UUID(),
            date: entity.date ?? Date()
        )
    }

    func addRecord(for trackerID: UUID, at date: Date) {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerID = trackerID
        entity.date = date

        do {
            try context.save()
        } catch {
            print("❌ Failed to save new record: \(error)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}

