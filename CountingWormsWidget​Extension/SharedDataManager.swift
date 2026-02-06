//
//  SharedDataManager.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import Foundation

// Shared data structure for widgets
struct SharedCalorieData: Codable {
    let remainingCalories: Int
    let totalCalories: Int
    let consumedCalories: Int
    let lastUpdated: Date
}

class SharedDataManager {
    static let shared = SharedDataManager()
    
    // IMPORTANT: Replace with your actual App Group identifier
    // You need to create this in Xcode's Signing & Capabilities
    private let appGroupID = "group.bram.CountingWorms"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private let calorieDataKey = "sharedCalorieData"
    
    // Save calorie data for widgets to access
    func saveCalorieData(remaining: Int, total: Int, consumed: Int) {
        let data = SharedCalorieData(
            remainingCalories: remaining,
            totalCalories: total,
            consumedCalories: consumed,
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: calorieDataKey)
        }
    }
    
    // Load calorie data (used by widgets)
    func loadCalorieData() -> SharedCalorieData? {
        guard let data = userDefaults?.data(forKey: calorieDataKey),
              let decoded = try? JSONDecoder().decode(SharedCalorieData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
