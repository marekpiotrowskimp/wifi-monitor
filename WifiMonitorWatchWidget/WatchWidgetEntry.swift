import WidgetKit
import Foundation

/// Data model for watchOS complication
/// Contains network information needed for display in complication
struct WatchWidgetEntry: TimelineEntry {
    /// Entry date (required by TimelineEntry)
    let date: Date
    
    /// WiFi network information
    let networkInfo: WiFiNetworkInfo
    
    /// Whether this is a placeholder (sample data)
    let isPlaceholder: Bool
    
    /// Placeholder for redacted view
    static var placeholder: WatchWidgetEntry {
        WatchWidgetEntry(
            date: Date(),
            networkInfo: .placeholder,
            isPlaceholder: true
        )
    }
    
    /// Snapshot for complication gallery
    static var snapshot: WatchWidgetEntry {
        WatchWidgetEntry(
            date: Date(),
            networkInfo: .placeholder,
            isPlaceholder: false
        )
    }
}
