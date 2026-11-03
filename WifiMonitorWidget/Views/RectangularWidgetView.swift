import SwiftUI
import WidgetKit

/// View for rectangular Lock Screen widget (accessoryRectangular)
/// Displays SSID, connection status, and IP address
struct RectangularWidgetView: View {
    let entry: WiFiWidgetEntry
    
    var body: some View {
        if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
            // Connected to WiFi
            VStack(alignment: .leading, spacing: 2) {
                // Row 1: Icon + SSID
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                        .font(.caption)
                        .widgetAccentable()
                    
                    Text(entry.networkInfo.ssid ?? "WiFi")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                }
                
                // Row 2: Connection status
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text("Connected")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                // Row 3: IP Address
                if let ip = entry.networkInfo.ipAddress {
                    Text(ip)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            // Not connected
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("No WiFi")
                        .font(.headline)
                    Text("Connect to a network")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryRectangular) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
    WiFiWidgetEntry(
        date: Date(),
        networkInfo: .empty,
        isPlaceholder: false
    )
}
