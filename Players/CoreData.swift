//
//  CoreData.swift
//  Players
//
//  Created by Temirlan on 13.02.2024.
//

import Foundation
import CoreData
final class CoreDataStack: ObservableObject {
    init (){}
    static let shared = CoreDataStack()
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
}
