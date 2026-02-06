//
//  CountingWormsWidget_Extension.swift
//  CountingWormsWidget​Extension
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
        
        print("🔍 Widget loading entry: Remaining=\(entry.remaining), Total=\(entry.total), Consumed=\(entry.consumed)")
        
        // Update every 15 minutes, but allow immediate refresh
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadEntry() -> CalorieEntry {
        if let data = SharedDataManager.shared.loadCalorieData() {
            print("✅ Widget loaded data from SharedDataManager: \(data.remainingCalories) cal remaining")
            return CalorieEntry(
                date: data.lastUpdated,
                remaining: data.remainingCalories,
                total: data.totalCalories,
                consumed: data.consumedCalories
            )
        } else {
            print("⚠️ Widget: No shared data found, using defaults")
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

// Small widget (home screen) - Heavy metal style
struct SmallWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            // Dark background with red undertones
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 6) {
                Text("CAL")
                    .font(.system(.caption2, design: .default, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.4))
                
                Text("\(entry.remaining)")
                    .font(.system(size: 56, weight: .black, design: .default))
                    .foregroundStyle(remainingGradient)
                    .shadow(color: remainingColor.opacity(0.8), radius: 10, x: 0, y: 0)
                    .minimumScaleFactor(0.5)
                
                Text("LEFT")
                    .font(.system(.caption2, design: .default, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return Color(red: 1.0, green: 0.1, blue: 0.1)
        } else if entry.remaining < 300 {
            return Color(red: 1.0, green: 0.4, blue: 0.0)
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.3)
        }
    }
    
    private var remainingGradient: LinearGradient {
        if entry.remaining < 0 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.0, blue: 0.0), Color(red: 0.8, green: 0.0, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if entry.remaining < 300 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.3, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.0, green: 1.0, blue: 0.4), Color(red: 0.0, green: 0.8, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Medium widget (home screen) - Heavy metal style
struct MediumWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("REMAINING")
                        .font(.system(.caption2, design: .default, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Text("\(entry.remaining)")
                        .font(.system(size: 52, weight: .black, design: .default))
                        .foregroundStyle(remainingGradient)
                        .shadow(color: remainingColor.opacity(0.8), radius: 8, x: 0, y: 0)
                    
                    Text("CAL")
                        .font(.system(.caption2, design: .default, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(entry.consumed)")
                            .font(.system(.title2, design: .default, weight: .black))
                            .foregroundStyle(Color(red: 1.0, green: 0.3, blue: 0.2))
                        Text("CONSUMED")
                            .font(.system(.caption2, design: .default, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 1)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(entry.total)")
                            .font(.system(.title2, design: .default, weight: .black))
                            .foregroundStyle(.white)
                        Text("DAILY TARGET")
                            .font(.system(.caption2, design: .default, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return Color(red: 1.0, green: 0.1, blue: 0.1)
        } else if entry.remaining < 300 {
            return Color(red: 1.0, green: 0.4, blue: 0.0)
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.3)
        }
    }
    
    private var remainingGradient: LinearGradient {
        if entry.remaining < 0 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.0, blue: 0.0), Color(red: 0.8, green: 0.0, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if entry.remaining < 300 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.3, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.0, green: 1.0, blue: 0.4), Color(red: 0.0, green: 0.8, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Large widget (home screen)
struct LargeWidgetView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.05),
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Title
                VStack(spacing: 4) {
                    Text("COUNTING WORMS")
                        .font(.system(size: 18, weight: .black, design: .default))
                        .tracking(2)
                        .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                        .shadow(color: Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.5), radius: 8, x: 0, y: 0)
                }
                
                // Main calorie display
                VStack(spacing: 4) {
                    Text("\(entry.remaining)")
                        .font(.system(size: 72, weight: .black, design: .default))
                        .foregroundStyle(remainingGradient)
                        .shadow(color: remainingColor.opacity(0.8), radius: 15, x: 0, y: 0)
                    
                    Text("REMAINING")
                        .font(.system(size: 12, weight: .black, design: .default))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                // Stats grid
                HStack(spacing: 40) {
                    VStack(spacing: 2) {
                        Text("\(entry.consumed)")
                            .font(.system(size: 32, weight: .black, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.4, blue: 0.0), Color(red: 1.0, green: 0.2, blue: 0.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.0).opacity(0.6), radius: 8, x: 0, y: 0)
                        Text("CONSUMED")
                            .font(.system(size: 9, weight: .black, design: .default))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    VStack(spacing: 2) {
                        Text("\(entry.total)")
                            .font(.system(size: 32, weight: .black, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.9, green: 0.2, blue: 0.2), Color(red: 0.7, green: 0.1, blue: 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 0.8, green: 0.1, blue: 0.1).opacity(0.6), radius: 8, x: 0, y: 0)
                        Text("TARGET")
                            .font(.system(size: 9, weight: .black, design: .default))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                // Footer
                Text("TAP TO LOG")
                    .font(.system(size: 10, weight: .black, design: .default))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.top, 4)
            }
            .padding()
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return Color(red: 1.0, green: 0.1, blue: 0.1)
        } else if entry.remaining < 300 {
            return Color(red: 1.0, green: 0.4, blue: 0.0)
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.3)
        }
    }
    
    private var remainingGradient: LinearGradient {
        if entry.remaining < 0 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.0, blue: 0.0), Color(red: 0.8, green: 0.0, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if entry.remaining < 300 {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.3, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.0, green: 1.0, blue: 0.4), Color(red: 0.0, green: 0.8, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Widget configuration
struct CountingWormsWidget_Extension: Widget {
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
    CountingWormsWidget_Extension()
} timeline: {
    CalorieEntry(date: Date(), remaining: 1500, total: 2000, consumed: 500)
    CalorieEntry(date: Date(), remaining: 800, total: 2000, consumed: 1200)
}
