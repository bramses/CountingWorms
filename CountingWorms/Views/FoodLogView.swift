//
//  FoodLogView.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import SwiftUI

struct FoodLogView: View {
    let entries: [FoodEntry]
    let onDelete: (FoodEntry) -> Void
    let onUpdate: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(entries, id: \.id) { entry in
                        FoodEntryCard(
                            entry: entry,
                            onDelete: { onDelete(entry) },
                            onUpdate: onUpdate
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Today's Food Log")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct FoodEntryCard: View {
    let entry: FoodEntry
    let onDelete: () -> Void
    let onUpdate: () -> Void
    
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Food image
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false) // Prevent image from blocking touches
            }
            
            // Food description and calories
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.foodDescription)
                            .font(.headline)
                        
                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Total Calories badge
                    Text("\(entry.estimatedCalories) cal")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange, in: Capsule())
                }
                
                // Serving controls
                HStack(spacing: 12) {
                    // Decrease serving
                    Button {
                        if entry.servings > 1 {
                            entry.servings -= 1
                            onUpdate()
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(entry.servings > 1 ? .blue : .gray)
                            .frame(width: 44, height: 44) // Larger tap target
                    }
                    .buttonStyle(.plain)
                    .disabled(entry.servings <= 1)
                    
                    // Serving count
                    VStack(spacing: 2) {
                        Text("\(entry.servings)")
                            .font(.title3.bold())
                        Text(entry.servings == 1 ? "serving" : "servings")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 60)
                    
                    // Increase serving
                    Button {
                        entry.servings += 1
                        onUpdate()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44) // Larger tap target
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Edit button
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil.circle.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Delete button
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                            .frame(width: 44, height: 44) // Larger tap target
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle()) // Ensure hit testing works correctly
        .sheet(isPresented: $showEditSheet) {
            EditEntrySheet(entry: entry, onUpdate: onUpdate)
        }
    }
}

struct EditEntrySheet: View {
    let entry: FoodEntry
    let onUpdate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var caloriesText: String = ""
    @State private var servingsText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    Text(entry.foodDescription)
                        .font(.headline)
                }
                
                Section("Calories per Serving") {
                    TextField("Calories", text: $caloriesText)
                        .keyboardType(.numberPad)
                }
                
                Section("Number of Servings") {
                    TextField("Servings", text: $servingsText)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Text("Total: \((Int(caloriesText) ?? entry.caloriesPerServing) * (Int(servingsText) ?? entry.servings)) calories")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let calories = Int(caloriesText) {
                            entry.caloriesPerServing = calories
                        }
                        if let servings = Int(servingsText), servings > 0 {
                            entry.servings = servings
                        }
                        onUpdate()
                        dismiss()
                    }
                }
            }
            .onAppear {
                caloriesText = String(entry.caloriesPerServing)
                servingsText = String(entry.servings)
            }
        }
    }
}
