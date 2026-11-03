import Foundation
import CoreLocation

/// Manager for handling location permissions
/// Required to fetch WiFi information (SSID) - Apple requires location permission for privacy reasons
final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var permissionStatus: LocationPermissionStatus = .notDetermined
    @Published var isAuthorized: Bool = false
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        updatePermissionStatus()
    }
    
    // MARK: - Public Methods
    
    /// Requests location permission from user
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Checks current permission status
    func checkPermission() {
        updatePermissionStatus()
    }
    
    /// Starts location updates - required for NEHotspotNetwork to work
    func startLocationUpdates() {
        if isAuthorized {
            locationManager.startUpdatingLocation()
            print("[LocationManager] Started location updates")
        }
    }
    
    /// Stops location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("[LocationManager] Stopped location updates")
    }
    
    // MARK: - Private Methods
    
    private func updatePermissionStatus() {
        let status = locationManager.authorizationStatus
        
        DispatchQueue.main.async { [weak self] in
            switch status {
            case .notDetermined:
                self?.permissionStatus = .notDetermined
                self?.isAuthorized = false
            case .restricted:
                self?.permissionStatus = .restricted
                self?.isAuthorized = false
            case .denied:
                self?.permissionStatus = .denied
                self?.isAuthorized = false
            case .authorizedAlways, .authorizedWhenInUse:
                self?.permissionStatus = .authorized
                self?.isAuthorized = true
                // Start location updates when authorized
                self?.startLocationUpdates()
            @unknown default:
                self?.permissionStatus = .notDetermined
                self?.isAuthorized = false
            }
            
            print("[LocationManager] Permission status: \(status.rawValue), isAuthorized: \(self?.isAuthorized ?? false)")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updatePermissionStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We don't need the actual location, just need location services active
        // for NEHotspotNetwork.fetchCurrent to work
        print("[LocationManager] Location updated - WiFi info should now be available")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] Location error: \(error.localizedDescription)")
    }
}
