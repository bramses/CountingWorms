//
//  SettingsView.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let calorieManager: CalorieManager
    
    @State private var dailyCalorieTarget: String = ""
    @State private var resetHour: Int = 0
    @State private var selectedProvider: LLMProvider = .openai
    @State private var apiKey: String = ""
    @State private var isTestingAPI = false
    @State private var testResult: String?
    @State private var showTestResult = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Calorie Target") {
                    HStack {
                        TextField("Calories", text: $dailyCalorieTarget)
                            .keyboardType(.numberPad)
                        Text("cal")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Day Reset Time") {
                    Picker("Reset Hour", selection: $resetHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section("AI Provider") {
                    Picker("Provider", selection: $selectedProvider) {
                        Text("OpenAI").tag(LLMProvider.openai)
                        Text("Claude").tag(LLMProvider.claude)
                    }
                    .pickerStyle(.segmented)
                    
                    SecureField("API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Text("The app uses \(selectedProvider.rawValue) to analyze food photos and estimate calories.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("API Test") {
                    Button {
                        Task {
                            await testAPIConnection()
                        }
                    } label: {
                        HStack {
                            if isTestingAPI {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isTestingAPI ? "Testing..." : "Test API Connection")
                        }
                    }
                    .disabled(isTestingAPI || apiKey.isEmpty)
                    
                    if let testResult = testResult {
                        Text(testResult)
                            .font(.caption)
                            .foregroundStyle(testResult.contains("✅") ? .green : .red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }
    
    private func loadCurrentSettings() {
        let settings = calorieManager.getSettings()
        dailyCalorieTarget = String(settings.dailyCalorieTarget)
        resetHour = settings.dayResetHour
        selectedProvider = settings.llmProvider
        apiKey = settings.apiKey
    }
    
    private func saveSettings() {
        let targetCalories = Int(dailyCalorieTarget) ?? 2000
        calorieManager.updateSettings(
            dailyTarget: targetCalories,
            resetHour: resetHour,
            provider: selectedProvider,
            apiKey: apiKey
        )
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date)
    }
    
    private func testAPIConnection() async {
        isTestingAPI = true
        testResult = nil
        
        // Create a more realistic test image with text
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            // Draw a white background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw text to simulate food
            let text = "🍕 Pizza\n500 calories"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let textRect = CGRect(x: 50, y: 100, width: 300, height: 100)
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        guard let imageData = testImage.jpegData(compressionQuality: 0.9) else {
            testResult = "❌ Failed to create test image"
            isTestingAPI = false
            return
        }
        
        let aiService = AIService()
        
        do {
            print("🔍 Testing \(selectedProvider.rawValue) API...")
            print("📝 API Key (first 10 chars): \(String(apiKey.prefix(10)))...")
            
            let result = try await aiService.analyzeFood(
                imageData: imageData,
                provider: selectedProvider,
                apiKey: apiKey
            )
            
            testResult = "✅ API Connection Successful!\nResponse: \(result.description)\nCalories: \(result.estimatedCalories)"
            print("✅ Test successful: \(result)")
            
        } catch let error as AIServiceError {
            testResult = "❌ API Test Failed:\n\(error.localizedDescription)"
            print("❌ Test failed: \(error)")
            
        } catch {
            testResult = "❌ Unexpected Error:\n\(error.localizedDescription)"
            print("❌ Unexpected error: \(error)")
        }
        
        isTestingAPI = false
    }
}
