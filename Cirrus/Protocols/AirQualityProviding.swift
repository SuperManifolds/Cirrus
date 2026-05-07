import Foundation

protocol AirQualityProviding: Sendable {
    func fetchAirQuality(for location: Location) async throws -> AirQuality
}

// MARK: - Mock

#if DEBUG
struct MockAirQualityProvider: AirQualityProviding {
    func fetchAirQuality(for location: Location) async throws -> AirQuality {
        AirQuality(
            aqi: 35,
            aqiCategory: .fair,
            pm25: 8.5,
            pm10: 15.2,
            ozone: 62,
            nitrogenDioxide: 12,
            sulphurDioxide: 3,
            carbonMonoxide: 210,
            timestamp: Date()
        )
    }
}
#endif
