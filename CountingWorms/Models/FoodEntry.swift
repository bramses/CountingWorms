//
//  FoodEntry.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var timestamp: Date
    var imageData: Data?
    var foodDescription: String
    var caloriesPerServing: Int // Base calories for one serving
    var servings: Int // Number of servings
    
    // Computed property for total calories
    var estimatedCalories: Int {
        return caloriesPerServing * servings
    }
    
    init(imageData: Data?, foodDescription: String, estimatedCalories: Int, servings: Int = 1) {
        self.id = UUID()
        self.timestamp = Date()
        self.imageData = imageData
        self.foodDescription = foodDescription
        self.caloriesPerServing = estimatedCalories
        self.servings = servings
    }
}
