//
//  Milestone2App.swift
//  Milestone2
//
//  Created by 庄慧 on 2025/6/21.
//

import SwiftUI
import SwiftData

@main
struct Milestone2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self, Milestone.self
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
            FolderListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
