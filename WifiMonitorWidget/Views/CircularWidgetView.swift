import SwiftUI
import WidgetKit

/// View for circular Lock Screen widget (accessoryCircular)
/// Displays WiFi icon with connection status
struct CircularWidgetView: View {
    let entry: WiFiWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
            // Connected - WiFi icon with checkmark
            ZStack {
                AccessoryWidgetBackground()
                
                VStack(spacing: 2) {
                    Image(systemName: "wifi")
                        .font(.title3)
                        .widgetAccentable()
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
            }
        } else {
            // Not connected
            ZStack {
                AccessoryWidgetBackground()
                
                VStack(spacing: 2) {
                    Image(systemName: "wifi.slash")
                        .font(.title3)
                    Text("Off")
                        .font(.system(.caption2, design: .rounded))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
    WiFiWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
