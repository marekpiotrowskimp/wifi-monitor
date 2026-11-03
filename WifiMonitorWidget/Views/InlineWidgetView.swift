import SwiftUI
import WidgetKit

/// View for inline Lock Screen widget (accessoryInline)
/// Displays single line text with WiFi status
struct InlineWidgetView: View {
    let entry: WiFiWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected, let ssid = entry.networkInfo.ssid {
            // Connected - show SSID
            ViewThatFits {
                // Full version
                Label(
                    "WiFi: \(ssid)",
                    systemImage: "wifi"
                )
                
                // Short version
                Text(ssid)
            }
        } else {
            // Not connected
            Label("No WiFi", systemImage: "wifi.slash")
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryInline) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
    WiFiWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
