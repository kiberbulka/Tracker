//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

final class TrackerRecordStore: NSObject {
    
    private(set) var context: NSManagedObjectContext
    private(set) var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultController?.delegate = delegate
        }
    }
    
    init (context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    func addRecord(trackerId: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.trackerID = trackerId
        record.date = date
    }
    
    func fetchRecords(for trackerId: UUID) -> [TrackerRecord] {
        guard let recordsCoreData = fetchedResultController?.fetchedObjects else {
            return []
        }
        
        return recordsCoreData.compactMap { coreData in
            guard let coreDataTrackerId = coreData.trackerID,
                  let date = coreData.date,
                  coreDataTrackerId == trackerId else {
                return nil
            }
            
            return TrackerRecord(trackerID: coreDataTrackerId, date: date)
        }
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        try? controller.performFetch()
        self.fetchedResultController = controller
    }
    
    
}
