//
//  jejuonlWidgetLiveActivity.swift
//  jejuonlWidget
//
//  Created by meeeeeca Jeong on 8/14/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct jejuonlWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct jejuonlWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: jejuonlWidgetAttributes.self) { context in
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

extension jejuonlWidgetAttributes {
    fileprivate static var preview: jejuonlWidgetAttributes {
        jejuonlWidgetAttributes(name: "World")
    }
}

extension jejuonlWidgetAttributes.ContentState {
    fileprivate static var smiley: jejuonlWidgetAttributes.ContentState {
        jejuonlWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: jejuonlWidgetAttributes.ContentState {
         jejuonlWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: jejuonlWidgetAttributes.preview) {
   jejuonlWidgetLiveActivity()
} contentStates: {
    jejuonlWidgetAttributes.ContentState.smiley
    jejuonlWidgetAttributes.ContentState.starEyes
}
