import SwiftUI
import WidgetKit

/// View for small widget (systemSmall)
/// Displays WiFi icon, SSID, and connection status
struct SmallWidgetView: View {
    let entry: WiFiWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // WiFi icon with color based on connection status
            Image(systemName: entry.networkInfo.connectionType.icon)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(statusGradient)
                .symbolEffect(.pulse, isActive: !entry.networkInfo.isConnected)
            
            // Network name (SSID)
            Text(entry.networkInfo.ssid ?? "No WiFi")
                .font(.system(.headline, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Connection status
            if entry.networkInfo.isConnected && entry.networkInfo.connectionType == .wifi {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("Connected")
                        .font(.caption)
                }
                .foregroundStyle(.green)
            } else if !entry.networkInfo.isConnected {
                Text("Disconnected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    /// Status color based on connection state
    private var statusColor: Color {
        entry.networkInfo.isConnected ? .green : .gray
    }
    
    /// Gradient for icon
    private var statusGradient: LinearGradient {
        LinearGradient(
            colors: [statusColor, statusColor.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}
