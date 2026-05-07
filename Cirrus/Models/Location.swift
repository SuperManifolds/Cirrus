import CoreLocation
import Foundation

struct Location: Sendable, Codable, Equatable, Identifiable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let administrativeArea: String?

    var id: String { "\(latitude),\(longitude)" }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
