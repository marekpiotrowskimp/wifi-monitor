import SwiftUI
import WidgetKit

/// View for inline complication (accessoryInline)
/// Displays single line text with WiFi status
struct InlineComplicationView: View {
    let entry: WatchWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
            // Connected - show SSID
            if let ssid = entry.networkInfo.ssid {
                Label {
                    Text(ssid)
                } icon: {
                    Image(systemName: "wifi")
                }
            } else {
                Label {
                    Text("WiFi Connected")
                } icon: {
                    Image(systemName: "wifi")
                }
            }
        } else {
            // Not connected
            Label {
                Text("WiFi Off")
            } icon: {
                Image(systemName: "wifi.slash")
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryInline) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
    WatchWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
