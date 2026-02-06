//
//  HomeView.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import SwiftUI

struct HomeView: View {
    let calorieManager: CalorieManager
    @State private var showCamera = false
    @State private var showSettings = false
    @State private var showFoodLog = false
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var refreshTrigger = false
    
    private let aiService = AIService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Heavy metal inspired background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.05),  // Deep dark red
                        Color(red: 0.15, green: 0.05, blue: 0.05), // Dark burgundy
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Main calorie display - Heavy metal style
                    VStack(spacing: 12) {
                        Text("CALORIES REMAINING")
                            .font(.system(.caption, design: .default, weight: .heavy))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Text("\(calorieManager.getRemainingCalories())")
                            .font(.system(size: 96, weight: .black, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: remainingCaloriesGradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: remainingCaloriesColor.opacity(0.5), radius: 20, x: 0, y: 0)
                            .id(refreshTrigger)
                        
                        Text("\(calorieManager.getTodayCalories()) / \(calorieManager.getSettings().dailyCalorieTarget) CONSUMED")
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.5))
                            .id(refreshTrigger)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(remainingCaloriesColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Camera button - Heavy metal style
                    Button {
                        showCamera = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title2.bold())
                            Text("LOG FOOD")
                                .font(.system(.title3, design: .default, weight: .black))
                                .tracking(2)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.3, blue: 0.2),
                                    Color(red: 1.0, green: 0.5, blue: 0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.2).opacity(0.5), radius: 15, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .disabled(isAnalyzing)
                    
                    // Food log button
                    Button {
                        showFoodLog = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("VIEW LOG")
                                .font(.system(.subheadline, design: .default, weight: .bold))
                                .tracking(1)
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("COUNTING WORMS")
            .toolbarBackground(.black.opacity(0.95), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.3, blue: 0.2),
                                        Color(red: 1.0, green: 0.5, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { imageData in
                    Task {
                        await analyzeImage(imageData)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(calorieManager: calorieManager)
            }
            .sheet(isPresented: $showFoodLog) {
                FoodLogView(
                    entries: calorieManager.getTodayEntries(),
                    onDelete: { entry in
                        calorieManager.deleteEntry(entry)
                        refreshTrigger.toggle()
                    },
                    onUpdate: {
                        // Save changes and update widgets
                        calorieManager.saveChanges()
                        refreshTrigger.toggle()
                    }
                )
            }
            .onChange(of: refreshTrigger) {
                // This will cause the view to refresh
            }
            .overlay {
                if isAnalyzing {
                    AnalyzingOverlay()
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .openCamera)) { _ in
                showCamera = true
            }
        }
    }
    
    private var remainingCaloriesColor: Color {
        let remaining = calorieManager.getRemainingCalories()
        if remaining < 0 {
            return Color(red: 1.0, green: 0.1, blue: 0.1) // Intense red
        } else if remaining < 300 {
            return Color(red: 1.0, green: 0.4, blue: 0.0) // Aggressive orange
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.3) // Toxic green
        }
    }
    
    private var remainingCaloriesGradient: [Color] {
        let remaining = calorieManager.getRemainingCalories()
        if remaining < 0 {
            return [
                Color(red: 1.0, green: 0.0, blue: 0.0),
                Color(red: 0.8, green: 0.0, blue: 0.2)
            ]
        } else if remaining < 300 {
            return [
                Color(red: 1.0, green: 0.5, blue: 0.0),
                Color(red: 1.0, green: 0.3, blue: 0.0)
            ]
        } else {
            return [
                Color(red: 0.0, green: 1.0, blue: 0.4),
                Color(red: 0.0, green: 0.8, blue: 0.3)
            ]
        }
    }
    
    private func analyzeImage(_ imageData: Data) async {
        isAnalyzing = true
        errorMessage = nil
        
        let settings = calorieManager.getSettings()
        
        guard !settings.apiKey.isEmpty else {
            await MainActor.run {
                isAnalyzing = false
                errorMessage = "Please set up your API key in Settings"
            }
            return
        }
        
        do {
            let result = try await aiService.analyzeFood(
                imageData: imageData,
                provider: settings.llmProvider,
                apiKey: settings.apiKey
            )
            
            await MainActor.run {
                calorieManager.addEntry(
                    imageData: imageData,
                    description: result.description,
                    calories: result.estimatedCalories
                )
                isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                isAnalyzing = false
                errorMessage = "Failed to analyze image: \(error.localizedDescription)"
            }
        }
    }
}

struct AnalyzingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(2.0)
                    .tint(Color(red: 1.0, green: 0.3, blue: 0.2))
                
                Text("ANALYZING...")
                    .font(.system(.title3, design: .default, weight: .black))
                    .tracking(3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.3, blue: 0.2),
                                Color(red: 1.0, green: 0.5, blue: 0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.3, blue: 0.2),
                                        Color(red: 1.0, green: 0.5, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.2).opacity(0.5), radius: 20, x: 0, y: 0)
            )
        }
    }
}
