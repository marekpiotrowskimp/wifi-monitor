import SwiftUI
import WidgetKit

/// View for corner complication (accessoryCorner)
/// Displays WiFi icon with connection status text
struct CornerComplicationView: View {
    let entry: WatchWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
            // Connected - WiFi icon with status
            ZStack {
                AccessoryWidgetBackground()
                
                Image(systemName: "wifi")
                    .font(.title2)
                    .widgetAccentable()
            }
            .widgetLabel {
                Text("On")
            }
        } else {
            // Not connected
            ZStack {
                AccessoryWidgetBackground()
                
                Image(systemName: "wifi.slash")
                    .font(.title2)
            }
            .widgetLabel {
                Text("Off")
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryCorner) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
    WatchWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
