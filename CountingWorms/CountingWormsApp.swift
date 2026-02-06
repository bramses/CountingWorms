//
//  CountingWormsApp.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import SwiftUI
import SwiftData

@main
struct CountingWormsApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                FoodEntry.self,
                UserSettings.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(calorieManager: CalorieManager(modelContext: modelContainer.mainContext))
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .modelContainer(modelContainer)
    }
    
    private func handleURL(_ url: URL) {
        // Handle deep link from widgets
        if url.scheme == "countingworms" && url.host == "camera" {
            NotificationCenter.default.post(name: .openCamera, object: nil)
        }
    }
}

extension Notification.Name {
    static let openCamera = Notification.Name("openCamera")
}
