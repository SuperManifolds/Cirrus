import Foundation
import OSLog

struct OpenMeteoPollenService: PollenProviding {
    private let session: URLSession
    private static let baseURL = "https://air-quality-api.open-meteo.com/v1/air-quality"

    private static let currentParams = [
        "alder_pollen", "birch_pollen", "grass_pollen",
        "mugwort_pollen", "olive_pollen", "ragweed_pollen"
    ].joined(separator: ",")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPollen(for location: Location) async throws -> Pollen? {
        let url = try buildURL(for: location)
        Log.api.debug("Fetching pollen: \(url)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            Log.api.error("Pollen fetch failed: \(error.localizedDescription)")
            return nil
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                guard let date = formatter.date(from: string) else {
                    throw DecodingError.dataCorruptedError(
                        in: container, debugDescription: "Cannot decode date: \(string)"
                    )
                }
                return date
            }
            let decoded = try decoder.decode(PollenResponse.self, from: data)
            return mapResponse(decoded)
        } catch {
            Log.api.error("Pollen decode failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func buildURL(for location: Location) throws -> URL {
        guard var components = URLComponents(string: Self.baseURL) else {
            throw WeatherProviderError.networkError(underlying: URLError(.badURL))
        }
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "current", value: Self.currentParams),
            URLQueryItem(name: "domains", value: "cams_europe"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else {
            throw WeatherProviderError.networkError(underlying: URLError(.badURL))
        }
        return url
    }

    private func mapResponse(_ response: PollenResponse) -> Pollen? {
        let current = response.current
        let pollen = Pollen(
            alder: current.alderPollen,
            birch: current.birchPollen,
            grass: current.grassPollen,
            mugwort: current.mugwortPollen,
            olive: current.olivePollen,
            ragweed: current.ragweedPollen,
            timestamp: current.time
        )
        return pollen.hasData ? pollen : nil
    }
}

// MARK: - Response Models

private struct PollenResponse: Decodable {
    let current: PollenCurrent
}

private struct PollenCurrent: Decodable {
    let time: Date
    let alderPollen: Double?
    let birchPollen: Double?
    let grassPollen: Double?
    let mugwortPollen: Double?
    let olivePollen: Double?
    let ragweedPollen: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case alderPollen = "alder_pollen"
        case birchPollen = "birch_pollen"
        case grassPollen = "grass_pollen"
        case mugwortPollen = "mugwort_pollen"
        case olivePollen = "olive_pollen"
        case ragweedPollen = "ragweed_pollen"
    }
}
