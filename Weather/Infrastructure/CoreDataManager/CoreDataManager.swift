//
//  CoreDataManager.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//


import CoreData
import Foundation

class CoreDataManager {

    // Mark:- properties
    static let shared = CoreDataManager()

    private init() {}

    /// The persistent container for the application.
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    /// The background context for the application.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }

    /// The main context for the application.
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
