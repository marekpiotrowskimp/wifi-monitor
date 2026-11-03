import SwiftUI

/// Main watchOS app entry point
@main
struct WifiMonitorWatchApp: App {
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(locationManager)
        }
    }
}
