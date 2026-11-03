import WidgetKit
import SwiftUI

/// Main entry point for Widget Extension
@main
struct WifiMonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        WifiMonitorWidget()
    }
}

/// Definicja widgetu WiFi Monitor
struct WifiMonitorWidget: Widget {
    /// Unique widget identifier
    let kind: String = "WifiMonitorWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WiFiWidgetProvider()) { entry in
            WiFiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WiFi Monitor")
        .description("WiFi network status on your home screen")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

/// Main widget view - selects appropriate layout based on widget family
struct WiFiWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WiFiWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.placeholder
    WiFiWidgetEntry.snapshot
}

#Preview("Medium", as: .systemMedium) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}

#Preview("Circular", as: .accessoryCircular) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}

#Preview("Rectangular", as: .accessoryRectangular) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}

#Preview("Inline", as: .accessoryInline) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}
