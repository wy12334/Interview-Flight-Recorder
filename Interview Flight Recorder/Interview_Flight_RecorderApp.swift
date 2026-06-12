//
//  Interview_Flight_RecorderApp.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftUI
import SwiftData

@main
struct Interview_Flight_RecorderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
