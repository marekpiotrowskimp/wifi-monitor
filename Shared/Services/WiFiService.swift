import Foundation
import Network
import NetworkExtension

/// Service for monitoring WiFi network
/// Uses NWPathMonitor to monitor connection status
/// and NEHotspotNetwork to fetch WiFi information
final class WiFiService {
    
    // MARK: - Properties
    
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.wifimonitor.networkmonitor")
    
    private var currentPath: Network.NWPath?
    private var onNetworkUpdate: ((WiFiNetworkInfo) -> Void)?
    
    // MARK: - Initialization
    
    init() {
        print("[WiFiService] Initialized")
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Starts network monitoring
    /// - Parameter onUpdate: Callback called on each network state change
    func startMonitoring(onUpdate: @escaping (WiFiNetworkInfo) -> Void) {
        self.onNetworkUpdate = onUpdate
        print("[WiFiService] Starting monitoring...")
        
        pathMonitor.pathUpdateHandler = { [weak self] path in
            print("[WiFiService] Path update - status: \(path.status), interfaces: \(path.availableInterfaces.map { $0.type })")
            self?.currentPath = path
            self?.handlePathUpdate(path)
        }
        
        pathMonitor.start(queue: monitorQueue)
    }
    
    /// Stops network monitoring
    func stopMonitoring() {
        pathMonitor.cancel()
        onNetworkUpdate = nil
        print("[WiFiService] Stopped monitoring")
    }
    
    /// Forces refresh of network information
    func refresh() {
        print("[WiFiService] Manual refresh requested")
        if let path = currentPath {
            handlePathUpdate(path)
        } else {
            print("[WiFiService] No current path available, creating new monitor")
            fetchCurrentNetworkInfo { [weak self] info in
                self?.onNetworkUpdate?(info)
            }
        }
    }
    
    /// Fetches current WiFi network info (one-time)
    func fetchCurrentNetworkInfo(completion: @escaping (WiFiNetworkInfo) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "com.wifimonitor.fetch")
        
        monitor.pathUpdateHandler = { [weak self] path in
            monitor.cancel()
            
            let connectionType = self?.determineConnectionType(from: path) ?? .none
            let isConnected = path.status == .satisfied
            let ipAddress = self?.getIPAddress()
            
            print("[WiFiService] Fetch - connected: \(isConnected), type: \(connectionType)")
            
            if connectionType == .wifi && isConnected {
                self?.fetchWiFiInfo { ssid, bssid, signalStrength, isSecure in
                    let info = WiFiNetworkInfo(
                        ssid: ssid,
                        bssid: bssid,
                        signalStrength: signalStrength,
                        isSecure: isSecure,
                        isConnected: isConnected,
                        ipAddress: ipAddress,
                        connectionType: connectionType,
                        lastUpdated: Date()
                    )
                    print("[WiFiService] Created info - SSID: \(ssid ?? "nil"), signal: \(signalStrength?.description ?? "N/A")")
                    DispatchQueue.main.async {
                        completion(info)
                    }
                }
            } else {
                let info = WiFiNetworkInfo(
                    ssid: nil,
                    bssid: nil,
                    signalStrength: nil,
                    isSecure: false,
                    isConnected: isConnected,
                    ipAddress: ipAddress,
                    connectionType: connectionType,
                    lastUpdated: Date()
                )
                DispatchQueue.main.async {
                    completion(info)
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    // MARK: - Private Methods
    
    private func handlePathUpdate(_ path: Network.NWPath) {
        let connectionType = determineConnectionType(from: path)
        let isConnected = path.status == .satisfied
        let ipAddress = getIPAddress()
        
        print("[WiFiService] Handle path - connected: \(isConnected), type: \(connectionType), IP: \(ipAddress ?? "nil")")
        
        if connectionType == .wifi && isConnected {
            fetchWiFiInfo { [weak self] ssid, bssid, signalStrength, isSecure in
                let info = WiFiNetworkInfo(
                    ssid: ssid,
                    bssid: bssid,
                    signalStrength: signalStrength,
                    isSecure: isSecure,
                    isConnected: isConnected,
                    ipAddress: ipAddress,
                    connectionType: connectionType,
                    lastUpdated: Date()
                )
                print("[WiFiService] WiFi info - SSID: \(ssid ?? "nil"), BSSID: \(bssid ?? "nil"), signal: \(signalStrength?.description ?? "N/A"), secure: \(isSecure)")
                DispatchQueue.main.async {
                    self?.onNetworkUpdate?(info)
                }
            }
        } else {
            let info = WiFiNetworkInfo(
                ssid: nil,
                bssid: nil,
                signalStrength: nil,
                isSecure: false,
                isConnected: isConnected,
                ipAddress: ipAddress,
                connectionType: connectionType,
                lastUpdated: Date()
            )
            print("[WiFiService] Non-WiFi connection or disconnected")
            DispatchQueue.main.async { [weak self] in
                self?.onNetworkUpdate?(info)
            }
        }
    }
    
    private func determineConnectionType(from path: Network.NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .none
        }
    }
    
    /// Fetches WiFi info using NEHotspotNetwork API
    /// Note: signalStrength and isSecure require NEHotspotHelper entitlement from Apple.
    /// Without this entitlement, the API returns 0.0 for signal and false for isSecure.
    /// We convert 0.0 signal to nil to indicate "not available".
    private func fetchWiFiInfo(completion: @escaping (String?, String?, Double?, Bool) -> Void) {
        print("[WiFiService] Fetching WiFi info via NEHotspotNetwork...")
        
        NEHotspotNetwork.fetchCurrent { network in
            if let network = network {
                print("[WiFiService] NEHotspotNetwork returned network: \(network.ssid)")
                
                #if os(iOS)
                // signalStrength and isSecure require NEHotspotHelper entitlement
                // Without it, signalStrength returns 0.0 and isSecure returns false
                // We convert 0.0 to nil to indicate "not available"
                let rawSignal = network.signalStrength
                let signalStrength: Double? = rawSignal > 0 ? rawSignal : nil
                
                // isSecure is also unreliable without the entitlement
                // Only trust it if we have valid signal strength
                let isSecure = signalStrength != nil ? network.isSecure : false
                
                print("[WiFiService] Raw signal: \(rawSignal), processed: \(signalStrength?.description ?? "nil")")
                
                completion(
                    network.ssid,
                    network.bssid,
                    signalStrength,
                    isSecure
                )
                #else
                // On watchOS these properties are not available
                completion(
                    network.ssid,
                    network.bssid,
                    nil,
                    false
                )
                #endif
            } else {
                // No permission or no network
                print("[WiFiService] NEHotspotNetwork returned nil - check location permissions!")
                completion(nil, nil, nil, false)
            }
        }
    }
    
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        
        defer { freeifaddrs(ifaddr) }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            // Looking for IPv4 (AF_INET)
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                
                // en0 is WiFi on iOS, en1 can be Ethernet
                if name == "en0" || name == "en1" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    )
                    address = String(cString: hostname)
                    break
                }
            }
        }
        
        return address
    }
}
