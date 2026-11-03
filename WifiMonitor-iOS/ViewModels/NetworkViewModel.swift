import SwiftUI
import Combine

/// ViewModel for the main iOS view
/// Uses @Observable (iOS 17+) for reactive UI updates
@Observable
final class NetworkViewModel {
    
    // MARK: - Published Properties
    
    var networkInfo: WiFiNetworkInfo = .empty
    var isLoading: Bool = false
    var errorMessage: String?
    var lastRefreshDate: Date?
    
    // MARK: - Private Properties
    
    private let wifiService = WiFiService()
    private weak var locationManager: LocationManager?
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var isConnected: Bool {
        networkInfo.isConnected
    }
    
    var hasWiFi: Bool {
        networkInfo.connectionType == .wifi
    }
    
    /// Returns formatted last update time
    var formattedLastUpdate: String {
        guard let date = lastRefreshDate else {
            return "Never"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Initialization
    
    init() {}
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Configures the view model with a shared LocationManager
    /// Must be called before using the view model
    /// - Parameter locationManager: Shared LocationManager instance
    func configure(with locationManager: LocationManager) {
        self.locationManager = locationManager
        setupLocationObserver()
        
        // Start monitoring if already authorized
        if locationManager.isAuthorized {
            startMonitoring()
        }
    }
    
    /// Starts network monitoring
    func startMonitoring() {
        guard let locationManager = locationManager else {
            print("[NetworkViewModel] LocationManager not configured")
            errorMessage = "App not properly configured"
            return
        }
        
        guard locationManager.isAuthorized else {
            print("[NetworkViewModel] Cannot start monitoring - location not authorized")
            errorMessage = "Location permission required to access WiFi info"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("[NetworkViewModel] Starting monitoring...")
        
        // Ensure location updates are running (required for NEHotspotNetwork)
        locationManager.startLocationUpdates()
        
        // Small delay to ensure location is active before WiFi fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.wifiService.startMonitoring { [weak self] info in
                print("[NetworkViewModel] Received network info - SSID: \(info.ssid ?? "nil"), signal: \(info.signalStrength)")
                self?.networkInfo = info
                self?.lastRefreshDate = Date()
                self?.isLoading = false
                
                // Save to App Groups for widgets
                SharedDataManager.shared.saveNetworkInfo(info)
            }
        }
        
        // Auto-refresh every 10 seconds
        startAutoRefresh(interval: 10)
    }
    
    /// Stops network monitoring
    func stopMonitoring() {
        wifiService.stopMonitoring()
        locationManager?.stopLocationUpdates()
        stopAutoRefresh()
    }
    
    /// Manual refresh of network data
    func refresh() {
        guard let locationManager = locationManager else { return }
        
        isLoading = true
        
        // Ensure location updates are active before refresh
        locationManager.startLocationUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.wifiService.refresh()
        }
    }
    
    /// Starts automatic refresh at specified interval
    func startAutoRefresh(interval: TimeInterval) {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.wifiService.refresh()
        }
    }
    
    /// Stops automatic refresh
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Private Methods
    
    /// Sets up observer for location authorization changes
    private func setupLocationObserver() {
        guard let locationManager = locationManager else { return }
        
        locationManager.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorized in
                print("[NetworkViewModel] Location authorization changed: \(isAuthorized)")
                if isAuthorized {
                    self?.startMonitoring()
                } else {
                    self?.errorMessage = "Location permission required to access WiFi info"
                }
            }
            .store(in: &cancellables)
    }
}
