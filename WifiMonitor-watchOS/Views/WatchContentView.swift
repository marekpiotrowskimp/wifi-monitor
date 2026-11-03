import SwiftUI

/// Main view for Apple Watch - compact and readable
struct WatchContentView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    @State private var viewModel = WatchNetworkViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Permission request
                    if !locationManager.isAuthorized {
                        WatchPermissionView(locationManager: locationManager)
                    }
                    
                    // Main status icon
                    WatchStatusIcon(
                        isConnected: viewModel.isConnected,
                        connectionType: viewModel.networkInfo.connectionType
                    )
                    
                    // Network name or status
                    Text(viewModel.statusText)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    if viewModel.hasWiFi && viewModel.isConnected {
                        // Signal strength
                        WatchSignalView(strength: viewModel.networkInfo.signalStrength)
                        
                        // Details
                        WatchNetworkDetails(networkInfo: viewModel.networkInfo)
                    } else if viewModel.isConnected {
                        // Other connection
                        Text(viewModel.networkInfo.connectionType.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No connection")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("WiFi")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            locationManager.checkPermission()
        }
    }
}

// MARK: - Watch Permission View

struct WatchPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.slash.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            
            Text("Location required")
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Button("Allow") {
                locationManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding()
    }
}

// MARK: - Watch Status Icon

struct WatchStatusIcon: View {
    let isConnected: Bool
    let connectionType: ConnectionType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isConnected ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: connectionType.icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(isConnected ? .green : .red)
        }
    }
}

// MARK: - Watch Signal View

struct WatchSignalView: View {
    let strength: Double?
    
    var body: some View {
        VStack(spacing: 6) {
            // Signal strength bar
            WatchSignalBar(strength: strength)
            
            // Percentage value or N/A
            if let strength = strength {
                HStack(spacing: 4) {
                    Text("\(Int(strength * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(signalColor(for: strength))
                    
                    Text(signalDescription(for: strength))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 4) {
                    Text("N/A")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text("No data")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func signalColor(for strength: Double) -> Color {
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
    
    private func signalDescription(for strength: Double) -> String {
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return "Excellent"
        case 50..<75: return "Good"
        case 25..<50: return "Fair"
        default: return "Poor"
        }
    }
}

// MARK: - Watch Network Details

struct WatchNetworkDetails: View {
    let networkInfo: WiFiNetworkInfo
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            // Security
            HStack {
                Image(systemName: networkInfo.isSecure ? "lock.fill" : "lock.open.fill")
                    .foregroundStyle(networkInfo.isSecure ? .green : .red)
                
                Text(networkInfo.isSecure ? "Secured" : "Open")
                    .font(.caption)
            }
            
            // IP if available
            if let ip = networkInfo.ipAddress {
                HStack {
                    Image(systemName: "number")
                        .foregroundStyle(.secondary)
                    
                    Text(ip)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WatchContentView()
        .environmentObject(LocationManager())
}
