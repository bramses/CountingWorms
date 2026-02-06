//
//  LockScreenWidget.swift
//  CountingWormsWidget​Extension
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
            
            VStack(spacing: 1) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(remainingColor)
                
                Text("\(entry.remaining)")
                    .font(.system(size: 22, weight: .black, design: .default))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(remainingColor)
                
                Text("CAL")
                    .font(.system(size: 7, weight: .black, design: .default))
                    .tracking(1)
                    .foregroundColor(remainingColor.opacity(0.7))
            }
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return Color(red: 1.0, green: 0.2, blue: 0.2)
        } else if entry.remaining < 300 {
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.4)
        }
    }
}

// Rectangular lock screen widget
struct RectangularLockScreenView: View {
    let entry: CalorieEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                Text("COUNTING WORMS")
                    .font(.system(size: 11, weight: .black, design: .default))
                    .tracking(1)
                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(entry.remaining)")
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundStyle(remainingColor)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(entry.consumed)/\(entry.total)")
                        .font(.system(size: 11, weight: .black, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                    Text("USED/TARGET")
                        .font(.system(size: 7, weight: .black, design: .default))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
    
    private var remainingColor: Color {
        if entry.remaining < 0 {
            return Color(red: 1.0, green: 0.2, blue: 0.2)
        } else if entry.remaining < 300 {
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        } else {
            return Color(red: 0.0, green: 1.0, blue: 0.4)
        }
    }
}

// Inline lock screen widget
struct InlineLockScreenView: View {
    let entry: CalorieEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "fork.knife")
                .font(.system(size: 10, weight: .black))
            Text("\(entry.remaining) CAL LEFT")
                .font(.system(size: 12, weight: .black, design: .default))
                .tracking(0.5)
        }
        .widgetURL(URL(string: "countingworms://camera"))
    }
}
