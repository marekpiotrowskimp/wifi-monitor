import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Manager for sharing data between main app and widgets
/// Uses App Groups for saving/reading data
final class SharedDataManager {
    
    // MARK: - Singleton
    
    static let shared = SharedDataManager()
    
    // MARK: - Constants
    
    /// App Group name (must be the same in all targets)
    private let suiteName = "group.com.marek.piotrowski.wifimonitor"
    
    /// Key for storing network info
    private let networkInfoKey = "currentNetworkInfo"
    
    /// Key for storing last update date
    private let lastUpdateKey = "lastUpdateDate"
    
    // MARK: - Properties
    
    /// UserDefaults for App Group
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Saves network info to App Group
    /// Called by main app on each update
    /// - Parameter info: Current WiFi network info
    func saveNetworkInfo(_ info: WiFiNetworkInfo) {
        guard let defaults = userDefaults else {
            print("[SharedDataManager] Error: Cannot access App Group")
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(info)
            defaults.set(encoded, forKey: networkInfoKey)
            defaults.set(Date(), forKey: lastUpdateKey)
            defaults.synchronize()
            
            // Refresh all widgets
            reloadWidgets()
            
            print("[SharedDataManager] Saved network data: \(info.ssid ?? "no SSID")")
        } catch {
            print("[SharedDataManager] Encoding error: \(error)")
        }
    }
    
    /// Reads network info from App Group
    /// Called by widgets to display data
    /// - Returns: Network info or empty instance if no data
    func loadNetworkInfo() -> WiFiNetworkInfo {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: networkInfoKey)
        else {
            print("[SharedDataManager] No data in App Group")
            return .empty
        }
        
        do {
            let info = try JSONDecoder().decode(WiFiNetworkInfo.self, from: data)
            return info
        } catch {
            print("[SharedDataManager] Decoding error: \(error)")
            return .empty
        }
    }
    
    /// Returns the date of last data update
    /// - Returns: Last update date or nil
    func lastUpdateDate() -> Date? {
        userDefaults?.object(forKey: lastUpdateKey) as? Date
    }
    
    /// Checks if data is fresh (not older than specified interval)
    /// - Parameter interval: Maximum data age in seconds
    /// - Returns: true if data is fresh
    func isDataFresh(within interval: TimeInterval = 900) -> Bool {
        guard let lastUpdate = lastUpdateDate() else { return false }
        return Date().timeIntervalSince(lastUpdate) < interval
    }
    
    /// Forces refresh of all widgets
    func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    /// Refreshes a specific widget by its identifier
    /// - Parameter kind: Widget identifier
    func reloadWidget(kind: String) {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        #endif
    }
}
