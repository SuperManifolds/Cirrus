import Combine
import CoreLocation
import Foundation

@MainActor
protocol LocationProviding: AnyObject {
    var currentLocation: Location? { get }
    var currentLocationPublisher: Published<Location?>.Publisher { get }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestAuthorization()
    func requestLocation()
    func search(query: String) async throws -> [Location]
}

// MARK: - Mock

#if DEBUG
@MainActor
final class MockLocationProvider: LocationProviding {
    @Published var currentLocation: Location?
    var currentLocationPublisher: Published<Location?>.Publisher { $currentLocation }
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways

    init(location: Location? = Location(
        name: "Oslo",
        latitude: 59.91,
        longitude: 10.75,
        country: "Norway",
        administrativeArea: "Oslo"
    )) {
        self.currentLocation = location
    }

    func requestAuthorization() {}
    func requestLocation() {}

    func search(query: String) async throws -> [Location] {
        [
            Location(name: "Oslo", latitude: 59.91, longitude: 10.75,
                     country: "Norway", administrativeArea: "Oslo"),
            Location(name: "London", latitude: 51.51, longitude: -0.13,
                     country: "United Kingdom", administrativeArea: "England"),
            Location(name: "New York", latitude: 40.71, longitude: -74.01,
                     country: "United States", administrativeArea: "New York")
        ].filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
#endif
