import SwiftUI

/// Detailed network info view for watchOS
struct WatchNetworkInfo: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        List {
            // Connection section
            Section("Connection") {
                WatchInfoRow(
                    icon: "wifi",
                    label: "SSID",
                    value: networkInfo.ssid ?? "Unknown"
                )
                
                WatchInfoRow(
                    icon: networkInfo.isSecure ? "lock.fill" : "lock.open.fill",
                    label: "Security",
                    value: networkInfo.isSecure ? "Active" : "None"
                )
            }
            
            // Signal section
            Section("Signal") {
                VStack(spacing: 8) {
                    WatchCircularSignal(strength: networkInfo.signalStrength)
                    
                    Text(networkInfo.signalDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            // Technical details section
            Section("Details") {
                if let bssid = networkInfo.bssid {
                    WatchInfoRow(
                        icon: "antenna.radiowaves.left.and.right",
                        label: "BSSID",
                        value: bssid
                    )
                }
                
                if let ip = networkInfo.ipAddress {
                    WatchInfoRow(
                        icon: "number",
                        label: "IP",
                        value: ip
                    )
                }
                
                WatchInfoRow(
                    icon: "network",
                    label: "Type",
                    value: networkInfo.connectionType.rawValue
                )
            }
        }
        .listStyle(.carousel)
    }
}

/// Single info row for watchOS
struct WatchInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            Spacer()
        }
    }
}

/// Compact status view for complications
struct WatchCompactStatus: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: networkInfo.isConnected ? "wifi" : "wifi.slash")
                .font(.caption2)
            
            if networkInfo.isConnected {
                Text("\(networkInfo.signalPercentage)%")
                    .font(.caption2)
            }
        }
        .foregroundStyle(networkInfo.isConnected ? .green : .secondary)
    }
}

/// View for large complication
struct WatchLargeComplication: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: networkInfo.connectionType.icon)
                .font(.title3)
                .foregroundStyle(networkInfo.isConnected ? .green : .secondary)
            
            if let ssid = networkInfo.ssid {
                Text(ssid)
                    .font(.caption2)
                    .lineLimit(1)
            }
            
            if networkInfo.isConnected && networkInfo.connectionType == .wifi {
                Text("\(networkInfo.signalPercentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
}

// MARK: - Preview

#Preview("Network Info") {
    WatchNetworkInfo(networkInfo: WiFiNetworkInfo(
        ssid: "MyWiFi",
        bssid: "AA:BB:CC:DD:EE:FF",
        signalStrength: 0.75,
        isSecure: true,
        isConnected: true,
        ipAddress: "192.168.1.100",
        connectionType: .wifi,
        lastUpdated: Date()
    ))
}
