//
//  ObservationLearningApp.swift
//  ObservationLearning
//
//  Created by differenz53 on 02/09/24.
//

import SwiftUI

@main
struct ObservationLearningApp: App {
    
    var dataController = DataController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.context)
        }
    }
}
