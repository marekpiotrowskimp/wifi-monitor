import SwiftUI

/// Main iOS app entry point
@main
struct WifiMonitorApp: App {
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
