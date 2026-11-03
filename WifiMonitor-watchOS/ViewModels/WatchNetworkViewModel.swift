import SwiftUI
import Combine

/// ViewModel for watchOS - optimized for battery efficiency
@Observable
final class WatchNetworkViewModel {
    
    // MARK: - Properties
    
    var networkInfo: WiFiNetworkInfo = .empty
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let wifiService = WiFiService()
    private var refreshTimer: Timer?
    
    // MARK: - Computed Properties
    
    var isConnected: Bool {
        networkInfo.isConnected
    }
    
    var hasWiFi: Bool {
        networkInfo.connectionType == .wifi
    }
    
    var statusText: String {
        if !isConnected {
            return "Disconnected"
        }
        return networkInfo.ssid ?? "Connected"
    }
    
    var signalText: String {
        "\(networkInfo.signalPercentage)%"
    }
    
    // MARK: - Initialization
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        isLoading = true
        
        wifiService.startMonitoring { [weak self] info in
            self?.networkInfo = info
            self?.isLoading = false
            
            // Save to App Groups for complications
            SharedDataManager.shared.saveNetworkInfo(info)
        }
        
        // On watch, refresh less frequently - every 30 seconds
        startAutoRefresh(interval: 30)
    }
    
    func stopMonitoring() {
        wifiService.stopMonitoring()
        stopAutoRefresh()
    }
    
    func refresh() {
        isLoading = true
        wifiService.refresh()
    }
    
    // MARK: - Private Methods
    
    private func startAutoRefresh(interval: TimeInterval) {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.wifiService.refresh()
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
