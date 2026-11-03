import SwiftUI

/// Badge showing network security status
struct SecurityBadge: View {
    let isSecure: Bool
    /// If false, security status is unreliable (iOS restriction)
    var isReliable: Bool = true
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundStyle(foregroundColor)
        .clipShape(Capsule())
    }
    
    private var iconName: String {
        if !isReliable {
            return "lock.trianglebadge.exclamationmark"
        }
        return isSecure ? "lock.fill" : "lock.open.fill"
    }
    
    private var statusText: String {
        if !isReliable {
            return "Unknown"
        }
        return isSecure ? "Secured" : "Open"
    }
    
    private var backgroundColor: Color {
        if !isReliable {
            return Color.gray.opacity(0.15)
        }
        return isSecure ? Color.green.opacity(0.15) : Color.red.opacity(0.15)
    }
    
    private var foregroundColor: Color {
        if !isReliable {
            return .gray
        }
        return isSecure ? .green : .red
    }
}

/// Network info card - used for displaying details
struct NetworkDetailCard: View {
    let title: String
    let icon: String
    let items: [(label: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(.headline)
            }
            
            Divider()
            
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Text(items[index].label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(items[index].value)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

/// Compact connection status icon
struct ConnectionStatusIcon: View {
    let connectionType: ConnectionType
    let isConnected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 44, height: 44)
            
            Image(systemName: connectionType.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }
    
    private var backgroundColor: Color {
        if isConnected {
            return .green.opacity(0.15)
        } else {
            return .red.opacity(0.15)
        }
    }
    
    private var iconColor: Color {
        isConnected ? .green : .red
    }
}

/// Widget for displaying a single value with label
struct InfoWidget: View {
    let label: String
    let value: String
    let icon: String
    var iconColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

/// Grid with basic network information
struct NetworkInfoGrid: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            // Signal strength - show N/A if not available
            InfoWidget(
                label: "Signal Strength",
                value: networkInfo.isSignalAvailable ? "\(networkInfo.signalPercentage)%" : "N/A",
                icon: "wifi",
                iconColor: signalColor
            )
            
            // Security - show unknown if signal not available (unreliable data)
            InfoWidget(
                label: "Security",
                value: networkInfo.securityDescription,
                icon: securityIcon,
                iconColor: securityColor
            )
            
            if let ip = networkInfo.ipAddress {
                InfoWidget(
                    label: "IP Address",
                    value: ip,
                    icon: "number"
                )
            }
            
            InfoWidget(
                label: "Type",
                value: networkInfo.connectionType.rawValue,
                icon: networkInfo.connectionType.icon
            )
        }
    }
    
    private var signalColor: Color {
        guard networkInfo.isSignalAvailable else { return .gray }
        switch networkInfo.signalPercentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
    
    private var securityIcon: String {
        guard networkInfo.isSignalAvailable else {
            return "lock.trianglebadge.exclamationmark"
        }
        return networkInfo.isSecure ? "lock.fill" : "lock.open.fill"
    }
    
    private var securityColor: Color {
        guard networkInfo.isSignalAvailable else { return .gray }
        return networkInfo.isSecure ? .green : .red
    }
}

// MARK: - Preview

#Preview("Security Badge") {
    VStack(spacing: 20) {
        SecurityBadge(isSecure: true, isReliable: true)
        SecurityBadge(isSecure: false, isReliable: true)
        SecurityBadge(isSecure: true, isReliable: false)
    }
}

#Preview("Connection Status Icon") {
    HStack(spacing: 20) {
        ConnectionStatusIcon(connectionType: .wifi, isConnected: true)
        ConnectionStatusIcon(connectionType: .wifi, isConnected: false)
        ConnectionStatusIcon(connectionType: .cellular, isConnected: true)
    }
}
