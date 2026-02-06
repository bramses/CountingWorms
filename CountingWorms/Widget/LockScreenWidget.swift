//
//  LockScreenWidget.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import WidgetKit
import SwiftUI

// Lock Screen Widget (Circular and Inline styles)
struct LockScreenCalorieWidget: Widget {
    let kind: String = "LockScreenCalorieWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalorieProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories")
        .description("Quick view of remaining calories")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetView: View {
    var entry: CalorieEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            CircularLockScreenView(entry: entry)
        }
    }
}

// Circular lock screen widget
struct CircularLockScreenView: View {
    let entry: CalorieEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Image(systemName: "fork.knife")
                    .font(.caption2)
                
                Text("\(entry.remaining)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("cal")
                    .font(.system(size: 8))
            }
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
}

// Rectangular lock screen widget
struct RectangularLockScreenView: View {
    let entry: CalorieEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.headline)
                Text("Calories Left")
                    .font(.headline)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.remaining)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(remainingColor)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.consumed)/\(entry.total)")
                        .font(.caption2)
                }
            }
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

// Inline lock screen widget
struct InlineLockScreenView: View {
    let entry: CalorieEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "fork.knife")
            Text("\(entry.remaining) cal left")
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
}

// Bundle both widgets together
// Note: This @main attribute should only be used when this file is in a Widget Extension target
// Remove the comment below when moving to Widget Extension:
// @main
struct CountingWormsWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountingWormsWidget()
        LockScreenCalorieWidget()
    }
}
