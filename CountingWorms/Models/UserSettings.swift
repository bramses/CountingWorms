//
//  UserSettings.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import Foundation
import SwiftData

enum LLMProvider: String, Codable {
    case openai = "OpenAI"
    case claude = "Claude"
}

@Model
final class UserSettings {
    var dailyCalorieTarget: Int
    var dayResetHour: Int // 0-23, hour when the day resets
    var llmProvider: LLMProvider
    var apiKey: String
    
    init(dailyCalorieTarget: Int = 2000, dayResetHour: Int = 0, llmProvider: LLMProvider = .openai, apiKey: String = "") {
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dayResetHour = dayResetHour
        self.llmProvider = llmProvider
        self.apiKey = apiKey
    }
}
