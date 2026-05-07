import Combine
import CoreLocation
import Foundation
import MapKit
import OSLog

@MainActor
final class LocationService: NSObject, LocationProviding {
    @Published var currentLocation: Location?
    var currentLocationPublisher: Published<Location?>.Publisher { $currentLocation }

    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorized else {
            Log.location.warning("Location not authorized, requesting...")
            requestAuthorization()
            return
        }
        manager.requestLocation()
    }

    func search(query: String) async throws -> [Location] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.compactMap { item -> Location? in
            let coordinate = item.location.coordinate
            let name = item.name ?? query
            return Location(
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                country: nil,
                administrativeArea: item.address?.shortAddress
            )
        }
    }

    @available(macOS, deprecated: 26.0, message: "CLGeocoder deprecated; revisit when MKAddress exposes locality")
    private func reverseGeocode(_ clLocation: CLLocation) {
        Task {
            do {
                let geocoder = CLGeocoder()
                let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
                guard let placemark = placemarks.first else { return }
                let name = placemark.locality
                    ?? placemark.administrativeArea
                    ?? String(localized: "Current Location")
                currentLocation = Location(
                    name: name,
                    latitude: clLocation.coordinate.latitude,
                    longitude: clLocation.coordinate.longitude,
                    country: placemark.country,
                    administrativeArea: placemark.administrativeArea
                )
                Log.location.debug("Resolved location: \(name)")
            } catch {
                Log.location.error("Reverse geocode failed: \(error.localizedDescription)")
                currentLocation = Location(
                    name: String(localized: "Current Location"),
                    latitude: clLocation.coordinate.latitude,
                    longitude: clLocation.coordinate.longitude,
                    country: nil,
                    administrativeArea: nil
                )
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            Log.location.error("Location update failed: \(error.localizedDescription)")
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if status == .authorizedAlways || status == .authorized {
                manager.requestLocation()
            }
        }
    }
}
