import WidgetKit
import Foundation

/// Provider that supplies data for the WiFi widget
/// Responsible for creating timeline with entries
struct WiFiWidgetProvider: TimelineProvider {
    
    /// Entry type
    typealias Entry = WiFiWidgetEntry
    
    /// Placeholder - displayed when widget is in redacted mode
    /// - Parameter context: Widget context
    /// - Returns: Placeholder entry
    func placeholder(in context: Context) -> WiFiWidgetEntry {
        .placeholder
    }
    
    /// Snapshot - displayed in widget gallery
    /// - Parameters:
    ///   - context: Widget context
    ///   - completion: Callback with entry
    func getSnapshot(in context: Context, completion: @escaping (WiFiWidgetEntry) -> Void) {
        if context.isPreview {
            // In preview we show sample data
            completion(.snapshot)
        } else {
            // In normal mode we fetch current data
            let info = SharedDataManager.shared.loadNetworkInfo()
            let entry = WiFiWidgetEntry(
                date: Date(),
                networkInfo: info,
                isPlaceholder: false
            )
            completion(entry)
        }
    }
    
    /// Timeline - main method that supplies data
    /// - Parameters:
    ///   - context: Widget context
    ///   - completion: Callback with timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<WiFiWidgetEntry>) -> Void) {
        // Fetch current data from App Groups
        let info = SharedDataManager.shared.loadNetworkInfo()
        
        let currentDate = Date()
        let entry = WiFiWidgetEntry(
            date: currentDate,
            networkInfo: info,
            isPlaceholder: false
        )
        
        // Next refresh in 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
