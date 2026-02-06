//
//  CountingWormsWidget.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import WidgetKit
import SwiftUI

// Widget timeline provider
struct CalorieProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalorieEntry {
        CalorieEntry(date: Date(), remaining: 1500, total: 2000, consumed: 500)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalorieEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CalorieEntry>) -> Void) {
        let entry = loadEntry()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadEntry() -> CalorieEntry {
        if let data = SharedDataManager.shared.loadCalorieData() {
            return CalorieEntry(
                date: data.lastUpdated,
                remaining: data.remainingCalories,
                total: data.totalCalories,
                consumed: data.consumedCalories
            )
        } else {
            return CalorieEntry(date: Date(), remaining: 2000, total: 2000, consumed: 0)
        }
    }
}

// Timeline entry
struct CalorieEntry: TimelineEntry {
    let date: Date
    let remaining: Int
    let total: Int
    let consumed: Int
}

// Home Screen Widget View
struct CalorieWidgetView: View {
    var entry: CalorieEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Small widget (home screen)
struct SmallWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("\(entry.remaining)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(remainingColor)
                
                Text("calories left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return .red
        } else if entry.remaining < 300 {
            return .orange
        } else {
            return .green
        }
    }
}

// Medium widget (home screen)
struct MediumWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(entry.remaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(remainingColor)
                    
                    Text("calories")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(entry.consumed)")
                            .font(.title3.bold())
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.blue)
                        Text("\(entry.total)")
                            .font(.title3.bold())
                    }
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return .red
        } else if entry.remaining < 300 {
            return .orange
        } else {
            return .green
        }
    }
}

// Large widget (home screen)
struct LargeWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    Text("Counting Worms")
                        .font(.headline)
                }
                
                VStack(spacing: 8) {
                    Text("\(entry.remaining)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(remainingColor)
                    
                    Text("CALORIES REMAINING")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(entry.consumed)")
                            .font(.title.bold())
                            .foregroundStyle(.orange)
                        Text("Consumed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(entry.total)")
                            .font(.title.bold())
                            .foregroundStyle(.blue)
                        Text("Daily Goal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("Tap to log food")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return .red
        } else if entry.remaining < 300 {
            return .orange
        } else {
            return .green
        }
    }
}

// Widget configuration
struct CountingWormsWidget: Widget {
    let kind: String = "CountingWormsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalorieProvider()) { entry in
            CalorieWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calorie Tracker")
        .description("Track your remaining calories for the day")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview
#Preview(as: .systemSmall) {
    CountingWormsWidget()
} timeline: {
    CalorieEntry(date: Date(), remaining: 1500, total: 2000, consumed: 500)
    CalorieEntry(date: Date(), remaining: 800, total: 2000, consumed: 1200)
}
