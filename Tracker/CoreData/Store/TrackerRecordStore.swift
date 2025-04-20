//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(){
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    
}
