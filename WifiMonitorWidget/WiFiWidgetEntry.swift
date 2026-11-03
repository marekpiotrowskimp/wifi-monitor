import WidgetKit
import Foundation

/// Data model for WiFi widget
/// Contains network information needed for display in widget
struct WiFiWidgetEntry: TimelineEntry {
    /// Entry date (required by TimelineEntry)
    let date: Date
    
    /// WiFi network information
    let networkInfo: WiFiNetworkInfo
    
    /// Whether this is a placeholder (sample data)
    let isPlaceholder: Bool
    
    /// Placeholder for redacted view
    static var placeholder: WiFiWidgetEntry {
        WiFiWidgetEntry(
            date: Date(),
            networkInfo: .placeholder,
            isPlaceholder: true
        )
    }
    
    /// Snapshot for widget gallery
    static var snapshot: WiFiWidgetEntry {
        WiFiWidgetEntry(
            date: Date(),
            networkInfo: .placeholder,
            isPlaceholder: false
        )
    }
}
