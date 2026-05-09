import Foundation
import OSLog

struct METNorwayNowcastService: Sendable {
    private let session: URLSession

    private static let baseURL = "https://api.met.no/weatherapi/nowcast/2.0/complete"
    private static let userAgent = "Cirrus/1.0 github.com/cirrus-weather"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchNowcast(for location: Location) async throws -> [MinuteForecast]? {
        guard var components = URLComponents(string: Self.baseURL) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(location.latitude)),
            URLQueryItem(name: "lon", value: String(location.longitude))
        ]
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            Log.api.error("MET Norway nowcast failed: \(error.localizedDescription)")
            return nil
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }

        guard httpResponse.statusCode == 200 else {
            Log.api.error("MET Norway nowcast HTTP \(httpResponse.statusCode)")
            return nil
        }

        do {
            return try decode(data)
        } catch {
            Log.api.error("MET Norway nowcast decode failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func decode(_ data: Data) throws -> [MinuteForecast]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(NowcastResponse.self, from: data)

        guard response.properties.meta.radarCoverage == "ok" else {
            return nil
        }

        var results: [MinuteForecast] = []
        for entry in response.properties.timeseries {
            let rate = entry.data.instant.details.precipitationRate ?? 0
            results.append(MinuteForecast(
                date: entry.time,
                precipitationIntensity: rate,
                precipitationChance: rate > 0 ? 100 : 0,
                precipitationType: nil
            ))
        }
        return results.isEmpty ? nil : results
    }
}

// MARK: - Response Models

private struct NowcastResponse: Decodable {
    let properties: NowcastProperties
}

private struct NowcastProperties: Decodable {
    let meta: NowcastMeta
    let timeseries: [NowcastEntry]
}

private struct NowcastMeta: Decodable {
    let radarCoverage: String

    enum CodingKeys: String, CodingKey {
        case radarCoverage = "radar_coverage"
    }
}

private struct NowcastEntry: Decodable {
    let time: Date
    let data: NowcastData
}

private struct NowcastData: Decodable {
    let instant: NowcastInstant
}

private struct NowcastInstant: Decodable {
    let details: NowcastDetails
}

private struct NowcastDetails: Decodable {
    let precipitationRate: Double?

    enum CodingKeys: String, CodingKey {
        case precipitationRate = "precipitation_rate"
    }
}
