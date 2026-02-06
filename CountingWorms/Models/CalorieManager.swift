//
//  CalorieManager.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import Foundation
import SwiftData
import WidgetKit

@Observable
class CalorieManager {
    private let modelContext: ModelContext
    private var settings: UserSettings?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }
    
    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        settings = try? modelContext.fetch(descriptor).first
        
        // Create default settings if none exist
        if settings == nil {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            settings = newSettings
            try? modelContext.save()
        }
    }
    
    func getSettings() -> UserSettings {
        if settings == nil {
            loadSettings()
        }
        return settings!
    }
    
    // Get all food entries for the current day
    func getTodayEntries() -> [FoodEntry] {
        let startOfDay = getStartOfCurrentDay()
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= startOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Calculate total calories consumed today
    func getTodayCalories() -> Int {
        getTodayEntries().reduce(0) { $0 + $1.estimatedCalories }
    }
    
    // Calculate remaining calories
    func getRemainingCalories() -> Int {
        let target = getSettings().dailyCalorieTarget
        let consumed = getTodayCalories()
        return target - consumed
    }
    
    // Get the start of the current day based on user's reset time
    func getStartOfCurrentDay() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let resetHour = getSettings().dayResetHour
        
        // Get today at reset hour
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = resetHour
        components.minute = 0
        components.second = 0
        
        guard let todayReset = calendar.date(from: components) else {
            return now
        }
        
        // If current time is before reset hour, use yesterday's reset time
        if now < todayReset {
            return calendar.date(byAdding: .day, value: -1, to: todayReset) ?? todayReset
        }
        
        return todayReset
    }
    
    // Add a new food entry
    func addEntry(imageData: Data?, description: String, calories: Int) {
        let entry = FoodEntry(imageData: imageData, foodDescription: description, estimatedCalories: calories)
        modelContext.insert(entry)
        try? modelContext.save()
        updateWidgetData()
    }
    
    // Delete a food entry
    func deleteEntry(_ entry: FoodEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        updateWidgetData()
    }
    
    // Save changes to existing entries (for servings/calories updates)
    func saveChanges() {
        try? modelContext.save()
        updateWidgetData()
    }
    
    // Update settings
    func updateSettings(dailyTarget: Int? = nil, resetHour: Int? = nil, provider: LLMProvider? = nil, apiKey: String? = nil) {
        let settings = getSettings()
        
        if let dailyTarget = dailyTarget {
            settings.dailyCalorieTarget = dailyTarget
        }
        if let resetHour = resetHour {
            settings.dayResetHour = resetHour
        }
        if let provider = provider {
            settings.llmProvider = provider
        }
        if let apiKey = apiKey {
            settings.apiKey = apiKey
        }
        
        try? modelContext.save()
        updateWidgetData()
    }
    
    // Update shared data for widgets
    private func updateWidgetData() {
        let remaining = getRemainingCalories()
        let total = getSettings().dailyCalorieTarget
        let consumed = getTodayCalories()
        
        print("📊 Updating widget data: Remaining=\(remaining), Total=\(total), Consumed=\(consumed)")
        
        SharedDataManager.shared.saveCalorieData(
            remaining: remaining,
            total: total,
            consumed: consumed
        )
        
        // Tell widgets to reload with a slight delay to ensure data is written
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🔄 Reloading all widget timelines")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
