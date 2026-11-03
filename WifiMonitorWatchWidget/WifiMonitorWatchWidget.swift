import WidgetKit
import SwiftUI

/// Main entry point for watchOS Widget Extension
@main
struct WifiMonitorWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        WifiMonitorWatchWidget()
    }
}

/// Definicja komplikacji WiFi Monitor dla watchOS
struct WifiMonitorWatchWidget: Widget {
    /// Unique widget identifier
    let kind: String = "WifiMonitorWatchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchWidgetProvider()) { entry in
            WatchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WiFi Monitor")
        .description("WiFi network status on your watch face")
        .supportedFamilies([
            .accessoryCorner,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

/// Main widget view - selects appropriate layout based on widget family
struct WatchWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WatchWidgetEntry
    
    var body: some View {
        switch family {
        case .accessoryCorner:
            CornerComplicationView(entry: entry)
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryInline:
            InlineComplicationView(entry: entry)
        default:
            CircularComplicationView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview("Corner", as: .accessoryCorner) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
}

#Preview("Circular", as: .accessoryCircular) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
}

#Preview("Rectangular", as: .accessoryRectangular) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
}

#Preview("Inline", as: .accessoryInline) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
}
