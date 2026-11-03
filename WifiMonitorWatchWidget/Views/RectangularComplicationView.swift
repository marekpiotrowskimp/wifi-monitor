import SwiftUI
import WidgetKit

/// View for rectangular complication (accessoryRectangular)
/// Displays SSID, connection status, and IP address
struct RectangularComplicationView: View {
    let entry: WatchWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
            // Connected - detailed info
            HStack(spacing: 8) {
                // WiFi icon
                Image(systemName: "wifi")
                    .font(.title2)
                    .widgetAccentable()
                    .frame(width: 40, height: 40)
                
                // Text info
                VStack(alignment: .leading, spacing: 2) {
                    // Network name
                    Text(entry.networkInfo.ssid ?? "WiFi")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                    
                    // Connection status
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("Connected")
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundStyle(.secondary)
                    
                    // IP Address (if available)
                    if let ip = entry.networkInfo.ipAddress {
                        Text(ip)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        } else {
            // Not connected
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Not Connected")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                    
                    Text("No WiFi network")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryRectangular) {
    WifiMonitorWatchWidget()
} timeline: {
    WatchWidgetEntry.snapshot
    WatchWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
