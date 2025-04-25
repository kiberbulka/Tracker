//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    init (context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
        super.init()
        
    }
    
    private func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        try? controller.performFetch()
        self.fetchedResultsController = controller
    }
    
    func addCategory(title: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try? context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        try? fetchedResultsController?.performFetch()
        
        return fetchedResultsController?.fetchedObjects?.compactMap { coreData in
            guard let title = coreData.title else {
                return nil
            }
            
            let trackerObjects = (coreData.trackers?.allObjects as? [TrackerCoreData]) ?? []
            let trackers = trackerObjects.compactMap { Tracker(from: $0) }
            
            return TrackerCategory(title: title, trackers: trackers)
        } ?? []
    }
    
    func isCategoryExists() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", "Домашний уют")
        
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = "Домашний уют"
        try? context.save()
        try? fetchedResultsController?.performFetch()
    }


 
    
    
}
