import Foundation
import Testing
@testable import Cirrus

struct OpenMeteoServiceTests {
    private let testLocation = Location(
        name: "Oslo",
        latitude: 59.91,
        longitude: 10.75,
        country: "Norway",
        administrativeArea: "Oslo"
    )

    // MARK: - JSON Decoding via fetchWeather

    @Test func decodesRealAPIResponse() async throws {
        let fixtureURL = Bundle(for: BundleToken.self).url(
            forResource: "open_meteo_response",
            withExtension: "json"
        )!
        let data = try Data(contentsOf: fixtureURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.open-meteo.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let service = OpenMeteoService(session: URLSession(configuration: config))
        let snapshot = try await service.fetchWeather(for: testLocation)

        #expect(snapshot.provider == .openMeteo)
        #expect(snapshot.location == testLocation)
        #expect(!snapshot.hourly.isEmpty)
        #expect(!snapshot.daily.isEmpty)
        #expect(snapshot.hourly.count == 24)
        #expect(snapshot.daily.count == 10)
    }

    @Test func currentWeatherHasValidFields() async throws {
        let snapshot = try await fetchFixture()

        #expect(snapshot.current.temperature.unit == .celsius)
        #expect(snapshot.current.humidity >= 0)
        #expect(snapshot.current.humidity <= 100)
        #expect(snapshot.current.uvIndex >= 0)
    }

    @Test func hourlyForecastHasDates() async throws {
        let snapshot = try await fetchFixture()

        for (idx, hour) in snapshot.hourly.enumerated() {
            if idx > 0 {
                #expect(hour.date > snapshot.hourly[idx - 1].date)
            }
        }
    }

    @Test func dailyForecastHasDates() async throws {
        let snapshot = try await fetchFixture()

        for (idx, day) in snapshot.daily.enumerated() {
            if idx > 0 {
                #expect(day.date > snapshot.daily[idx - 1].date)
            }
        }
    }

    @Test func weatherCodesMappedToConditions() async throws {
        let snapshot = try await fetchFixture()

        // All conditions should be valid enum cases (no crash = pass)
        _ = snapshot.current.condition.displayName
        for hour in snapshot.hourly {
            _ = hour.condition.sfSymbol
        }
        for day in snapshot.daily {
            _ = day.condition.sfSymbol
        }
    }

    @Test func networkErrorThrowsWeatherProviderError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let service = OpenMeteoService(session: URLSession(configuration: config))
        do {
            _ = try await service.fetchWeather(for: testLocation)
            Issue.record("Expected error to be thrown")
        } catch is WeatherProviderError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func httpErrorThrowsWeatherProviderError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.open-meteo.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let service = OpenMeteoService(session: URLSession(configuration: config))
        do {
            _ = try await service.fetchWeather(for: testLocation)
            Issue.record("Expected error to be thrown")
        } catch is WeatherProviderError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func rateLimitedThrowsRateLimitError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.open-meteo.com")!,
                statusCode: 429,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let service = OpenMeteoService(session: URLSession(configuration: config))
        do {
            _ = try await service.fetchWeather(for: testLocation)
            Issue.record("Expected error to be thrown")
        } catch let error as WeatherProviderError {
            if case .rateLimited = error {
                // Expected
            } else {
                Issue.record("Expected rateLimited, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helpers

    private func fetchFixture() async throws -> WeatherSnapshot {
        let fixtureURL = Bundle(for: BundleToken.self).url(
            forResource: "open_meteo_response",
            withExtension: "json"
        )!
        let data = try Data(contentsOf: fixtureURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.open-meteo.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let service = OpenMeteoService(session: URLSession(configuration: config))
        return try await service.fetchWeather(for: testLocation)
    }
}

// MARK: - Test Utilities

private final class BundleToken: NSObject {}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
