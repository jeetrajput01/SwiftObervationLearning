//
//  DataContoller.swift
//  Observation Framework
//
//  Created by differenz53 on 08/07/24.
//

import Foundation
import CoreData

class DataController {
    
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: "DataModel")
        self.container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("Core Data load successFully......")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
}
