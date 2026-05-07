import Foundation
import Testing
@testable import Cirrus

struct WeatherCacheServiceTests {
    private let oslo = Location(
        name: "Oslo", latitude: 59.91, longitude: 10.75,
        country: "Norway", administrativeArea: "Oslo"
    )

    private let bergen = Location(
        name: "Bergen", latitude: 60.39, longitude: 5.32,
        country: "Norway", administrativeArea: "Vestland"
    )

    @Test func storeAndRetrieve() async {
        let cache = WeatherCacheService(maxAge: 60, persistToDisk: false)
        let snapshot = makeSnapshot(location: oslo)
        await cache.store(snapshot)

        let cached = await cache.get(for: oslo)
        #expect(cached != nil)
        #expect(cached?.location == oslo)
    }

    @Test func missForDifferentLocation() async {
        let cache = WeatherCacheService(maxAge: 60, persistToDisk: false)
        await cache.store(makeSnapshot(location: oslo))

        let cached = await cache.get(for: bergen)
        #expect(cached == nil)
    }

    @Test func expiredEntryReturnsMiss() async {
        let cache = WeatherCacheService(maxAge: 0, persistToDisk: false)
        await cache.store(makeSnapshot(location: oslo))

        // maxAge=0 means it's already expired
        let cached = await cache.get(for: oslo)
        #expect(cached == nil)
    }

    @Test func invalidateClearsAll() async {
        let cache = WeatherCacheService(maxAge: 60, persistToDisk: false)
        await cache.store(makeSnapshot(location: oslo))
        await cache.store(makeSnapshot(location: bergen))

        await cache.invalidate()

        #expect(await cache.get(for: oslo) == nil)
        #expect(await cache.get(for: bergen) == nil)
    }

    @Test func nearbyCoordinatesHitSameKey() async {
        let cache = WeatherCacheService(maxAge: 60, persistToDisk: false)
        let loc1 = Location(
            name: "Oslo", latitude: 59.9100, longitude: 10.7500,
            country: nil, administrativeArea: nil
        )
        let loc2 = Location(
            name: "Oslo nearby", latitude: 59.9104, longitude: 10.7503,
            country: nil, administrativeArea: nil
        )

        await cache.store(makeSnapshot(location: loc1))
        let cached = await cache.get(for: loc2)
        #expect(cached != nil)
    }

    @Test func differentRoundedCoordinatesMiss() async {
        let cache = WeatherCacheService(maxAge: 60, persistToDisk: false)
        let loc1 = Location(
            name: "A", latitude: 59.91, longitude: 10.75,
            country: nil, administrativeArea: nil
        )
        let loc2 = Location(
            name: "B", latitude: 59.92, longitude: 10.75,
            country: nil, administrativeArea: nil
        )

        await cache.store(makeSnapshot(location: loc1))
        let cached = await cache.get(for: loc2)
        #expect(cached == nil)
    }

    // MARK: - Helpers

    private func makeSnapshot(location: Location) -> WeatherSnapshot {
        WeatherSnapshot(
            current: CurrentWeather(
                temperature: Measurement(value: 20, unit: .celsius),
                apparentTemperature: Measurement(value: 18, unit: .celsius),
                dewPoint: nil,
                condition: .clear,
                humidity: 50,
                windSpeed: Measurement(value: 10, unit: .kilometersPerHour),
                windDirection: 180,
                windGusts: nil,
                pressure: Measurement(value: 1013, unit: .hectopascals),
                uvIndex: 3,
                cloudCover: 10,
                visibility: Measurement(value: 10000, unit: .meters),
                precipitation: Measurement(value: 0, unit: .millimeters),
                rain: nil,
                snowfall: nil,
                snowDepth: nil,
                isDaytime: true,
                timestamp: Date()
            ),
            hourly: [],
            daily: [],
            minutely: nil,
            alerts: [],
            location: location,
            fetchedAt: Date(),
            provider: .openMeteo
        )
    }
}
