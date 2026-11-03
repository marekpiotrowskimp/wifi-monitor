import SwiftUI

/// Main iOS app view
struct ContentView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    @State private var viewModel = NetworkViewModel()
    @State private var isConfigured = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Check location permissions
                    if !locationManager.isAuthorized {
                        PermissionCard(locationManager: locationManager)
                    }
                    
                    // Error message if any
                    if let errorMessage = viewModel.errorMessage {
                        ErrorCard(message: errorMessage)
                    }
                    
                    // Connection status
                    ConnectionStatusCard(networkInfo: viewModel.networkInfo)
                    
                    // WiFi network info
                    if viewModel.hasWiFi && viewModel.isConnected {
                        NetworkInfoCard(networkInfo: viewModel.networkInfo)
                        
                        // Signal strength - show data if available, otherwise show explanation
                        if viewModel.networkInfo.isSignalAvailable {
                            SignalStrengthCard(networkInfo: viewModel.networkInfo)
                        } else {
                            SignalNotAvailableCard()
                        }
                        
                        // Technical details
                        TechnicalDetailsCard(networkInfo: viewModel.networkInfo)
                    } else if viewModel.isConnected {
                        // Non-WiFi connection
                        OtherConnectionCard(networkInfo: viewModel.networkInfo)
                    } else {
                        // No connection
                        NoConnectionCard()
                    }
                    
                    // Debug info (shows what's happening)
                    DebugInfoCard(networkInfo: viewModel.networkInfo, isLoading: viewModel.isLoading)
                    
                    // Last update
                    LastUpdateFooter(formattedDate: viewModel.formattedLastUpdate)
                }
                .padding()
            }
            .navigationTitle("WiFi Monitor")
            .refreshable {
                viewModel.refresh()
                // Wait briefly for refresh
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onAppear {
            if !isConfigured {
                viewModel.configure(with: locationManager)
                isConfigured = true
            }
        }
    }
}

// MARK: - Permission Card

struct PermissionCard: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Permission Required")
                .font(.headline)
            
            Text("To display the WiFi network name (SSID), the app needs location access. This is an Apple requirement for privacy reasons.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                locationManager.requestPermission()
            } label: {
                Text("Grant Permission")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Connection Status Card

struct ConnectionStatusCard: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(networkInfo.isConnected ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: networkInfo.connectionType.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(networkInfo.isConnected ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(networkInfo.isConnected ? "Connected" : "Disconnected")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(networkInfo.connectionType.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Network Info Card

struct NetworkInfoCard: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("WiFi Network")
                    .font(.headline)
                
                Spacer()
                
                SecurityBadge(isSecure: networkInfo.isSecure, isReliable: networkInfo.isSignalAvailable)
            }
            
            Divider()
            
            // SSID
            InfoRow(
                icon: "wifi",
                title: "Network Name (SSID)",
                value: networkInfo.ssid ?? "Unknown"
            )
            
            // BSSID
            if let bssid = networkInfo.bssid {
                InfoRow(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "BSSID",
                    value: bssid
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Signal Strength Card

struct SignalStrengthCard: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Signal Strength")
                    .font(.headline)
                
                Spacer()
                
                Text("\(networkInfo.signalPercentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(signalColor)
            }
            
            SignalStrengthBar(strength: networkInfo.signalStrength ?? 0)
            
            HStack {
                Text(networkInfo.signalDescription)
                    .font(.subheadline)
                    .foregroundStyle(signalColor)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var signalColor: Color {
        switch networkInfo.signalPercentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

// MARK: - Signal Not Available Card

struct SignalNotAvailableCard: View {
    @State private var showingInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                
                Text("Signal Strength")
                    .font(.headline)
                
                Spacer()
                
                Text("N/A")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 16))
                    
                    Text("Signal strength is not available due to iOS restrictions.")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                
                Text("Apple requires a special entitlement (NEHotspotHelper) to access WiFi signal strength. This entitlement is only granted to specific apps like network utilities and carrier apps.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Available data note
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("SSID, BSSID, and IP address are available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Technical Details Card

struct TechnicalDetailsCard: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Technical Details")
                .font(.headline)
            
            Divider()
            
            // IP Address
            if let ip = networkInfo.ipAddress {
                InfoRow(
                    icon: "number",
                    title: "IP Address",
                    value: ip
                )
            }
            
            // Connection Type
            InfoRow(
                icon: "network",
                title: "Connection Type",
                value: networkInfo.connectionType.rawValue
            )
            
            // Security - show with reliability indicator
            InfoRow(
                icon: networkInfo.isSignalAvailable ? (networkInfo.isSecure ? "lock.fill" : "lock.open.fill") : "lock.trianglebadge.exclamationmark.fill",
                title: "Security",
                value: networkInfo.securityDescription
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Other Connection Card

struct OtherConnectionCard: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: networkInfo.connectionType.icon)
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text("Connected via \(networkInfo.connectionType.rawValue)")
                .font(.headline)
            
            if let ip = networkInfo.ipAddress {
                Text("IP: \(ip)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - No Connection Card

struct NoConnectionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("No Connection")
                .font(.headline)
            
            Text("Connect to a WiFi network to see details")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Last Update Footer

struct LastUpdateFooter: View {
    let formattedDate: String
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .font(.caption)
            
            Text("Last updated: \(formattedDate)")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Error Card

struct ErrorCard: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Debug Info Card

struct DebugInfoCard: View {
    let networkInfo: WiFiNetworkInfo
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Debug Info")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            Divider()
            
            Group {
                debugRow("Connected", value: networkInfo.isConnected ? "Yes" : "No")
                debugRow("Connection Type", value: networkInfo.connectionType.rawValue)
                debugRow("SSID", value: networkInfo.ssid ?? "nil")
                debugRow("BSSID", value: networkInfo.bssid ?? "nil")
                debugRow("Signal", value: networkInfo.signalStrength.map { String(format: "%.2f", $0) } ?? "N/A (iOS restriction)")
                debugRow("Signal Available", value: networkInfo.isSignalAvailable ? "Yes" : "No")
                debugRow("Is Secure", value: networkInfo.isSignalAvailable ? (networkInfo.isSecure ? "Yes" : "No") : "Unknown")
                debugRow("IP Address", value: networkInfo.ipAddress ?? "nil")
            }
            .font(.caption2)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func debugRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(value == "nil" || value.contains("N/A") ? .orange : .primary)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
