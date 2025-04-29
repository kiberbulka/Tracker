//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Olya on 19.04.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data store location: \(storeDescription.url?.absoluteString ?? "No URL")")
            }
        })
        return container
    }()

    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        } else {
            print("⚠️ No changes in context to save")
        }
    }

    
}

