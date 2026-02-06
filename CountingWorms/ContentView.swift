//
//  ContentView.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HomeView(calorieManager: CalorieManager(modelContext: modelContext))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FoodEntry.self, UserSettings.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
