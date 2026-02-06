//
//  CountingWormsWidget_ExtensionLiveActivity.swift
//  CountingWormsWidget​Extension
//
//  Created by Bram Adams on 2/5/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CountingWormsWidget_ExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CountingWormsWidget_ExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountingWormsWidget_ExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CountingWormsWidget_ExtensionAttributes {
    fileprivate static var preview: CountingWormsWidget_ExtensionAttributes {
        CountingWormsWidget_ExtensionAttributes(name: "World")
    }
}

extension CountingWormsWidget_ExtensionAttributes.ContentState {
    fileprivate static var smiley: CountingWormsWidget_ExtensionAttributes.ContentState {
        CountingWormsWidget_ExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CountingWormsWidget_ExtensionAttributes.ContentState {
         CountingWormsWidget_ExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CountingWormsWidget_ExtensionAttributes.preview) {
   CountingWormsWidget_ExtensionLiveActivity()
} contentStates: {
    CountingWormsWidget_ExtensionAttributes.ContentState.smiley
    CountingWormsWidget_ExtensionAttributes.ContentState.starEyes
}
