import Foundation

/// Model representing WiFi network information
struct WiFiNetworkInfo: Identifiable, Equatable, Codable {
    /// Unique identifier (not encoded)
    var id: UUID = UUID()
    
    /// Network name (SSID)
    var ssid: String?
    
    /// Access point MAC address
    var bssid: String?
    
    /// Signal strength (0.0 - 1.0), nil if not available
    /// Note: Signal strength requires NEHotspotHelper entitlement from Apple.
    /// Without this special entitlement, iOS returns 0.0 which we convert to nil.
    var signalStrength: Double?
    
    /// Whether the network is secured
    /// Note: This value may be unreliable without NEHotspotHelper entitlement.
    var isSecure: Bool
    
    /// Whether the device is connected to the network
    var isConnected: Bool
    
    /// Device IP address in the network
    var ipAddress: String?
    
    /// Connection type
    var connectionType: ConnectionType
    
    /// Last update date
    var lastUpdated: Date
    
    /// CodingKeys - UUID is not encoded (generated on decoding)
    enum CodingKeys: String, CodingKey {
        case ssid, bssid, signalStrength, isSecure
        case isConnected, ipAddress, connectionType, lastUpdated
    }
    
    /// Default empty instance
    static var empty: WiFiNetworkInfo {
        WiFiNetworkInfo(
            ssid: nil,
            bssid: nil,
            signalStrength: nil,
            isSecure: false,
            isConnected: false,
            ipAddress: nil,
            connectionType: .none,
            lastUpdated: Date()
        )
    }
    
    /// Placeholder for widgets - sample data with signal available
    static var placeholder: WiFiNetworkInfo {
        WiFiNetworkInfo(
            ssid: "WiFi Network",
            bssid: "00:00:00:00:00:00",
            signalStrength: 0.75,
            isSecure: true,
            isConnected: true,
            ipAddress: "192.168.1.100",
            connectionType: .wifi,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Signal Strength Computed Properties
    
    /// Returns true if signal strength data is available
    var isSignalAvailable: Bool {
        guard let signal = signalStrength else { return false }
        return signal > 0
    }
    
    /// Signal strength as percentage (0-100), returns 0 if not available
    var signalPercentage: Int {
        guard let signal = signalStrength else { return 0 }
        return Int(signal * 100)
    }
    
    /// Signal strength as optional percentage, nil if not available
    var signalPercentageOrNil: Int? {
        guard let signal = signalStrength, signal > 0 else { return nil }
        return Int(signal * 100)
    }
    
    /// Signal strength description
    var signalDescription: String {
        guard isSignalAvailable else {
            return "Not Available"
        }
        switch signalPercentage {
        case 75...100:
            return "Excellent"
        case 50..<75:
            return "Good"
        case 25..<50:
            return "Fair"
        default:
            return "Poor"
        }
    }
    
    /// Color name representing signal strength
    var signalColorName: String {
        guard isSignalAvailable else {
            return "gray"
        }
        switch signalPercentage {
        case 75...100:
            return "green"
        case 50..<75:
            return "yellow"
        case 25..<50:
            return "orange"
        default:
            return "red"
        }
    }
    
    /// Security status description
    var securityDescription: String {
        // If signal is not available, isSecure is also unreliable
        guard isSignalAvailable else {
            return "Unknown"
        }
        return isSecure ? "Secured" : "Open"
    }
}

/// Network connection type
enum ConnectionType: String, Codable {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case none = "None"
    
    var icon: String {
        switch self {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .ethernet:
            return "cable.connector"
        case .none:
            return "wifi.slash"
        }
    }
}

/// Location permission status
enum LocationPermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
    
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        }
    }
}

/// Network monitoring status
enum NetworkMonitoringStatus {
    case idle
    case monitoring
    case error(String)
    
    var isMonitoring: Bool {
        if case .monitoring = self {
            return true
        }
        return false
    }
}
