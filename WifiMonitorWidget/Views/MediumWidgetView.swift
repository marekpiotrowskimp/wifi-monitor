import SwiftUI
import WidgetKit

/// View for medium widget (systemMedium)
/// Displays detailed WiFi network information
struct MediumWidgetView: View {
    let entry: WiFiWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - icon and status
            VStack(spacing: 8) {
                // WiFi icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: entry.networkInfo.connectionType.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(statusColor)
                }
                
                // Connection status
                if entry.networkInfo.isConnected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("Connected")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.green)
                }
            }
            .frame(width: 80)
            
            // Right side - details
            VStack(alignment: .leading, spacing: 6) {
                // Network name
                Text(entry.networkInfo.ssid ?? "No connection")
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(1)
                
                if entry.networkInfo.isConnected {
                    // IP Address
                    Label {
                        Text(entry.networkInfo.ipAddress ?? "No IP")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "number")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    
                    // BSSID (Access Point)
                    if let bssid = entry.networkInfo.bssid {
                        Label {
                            Text(bssid)
                                .font(.caption)
                        } icon: {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Last update
                    Text("Updated: \(formattedTime)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Not connected to WiFi network")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    /// Status color based on connection
    private var statusColor: Color {
        entry.networkInfo.isConnected ? .green : .gray
    }
    
    /// Formatted last update time
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.networkInfo.lastUpdated)
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    WifiMonitorWidget()
} timeline: {
    WiFiWidgetEntry.snapshot
}
