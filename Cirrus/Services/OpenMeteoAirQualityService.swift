import Foundation
import OSLog

struct OpenMeteoAirQualityService: AirQualityProviding {
    private let session: URLSession
    private static let baseURL = "https://air-quality-api.open-meteo.com/v1/air-quality"

    private static let currentParams = [
        "european_aqi", "us_aqi", "pm10", "pm2_5",
        "ozone", "nitrogen_dioxide", "sulphur_dioxide", "carbon_monoxide"
    ].joined(separator: ",")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAirQuality(for location: Location) async throws -> AirQuality {
        let url = try buildURL(for: location)
        Log.api.debug("Fetching air quality: \(url)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherProviderError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherProviderError.networkError(underlying: URLError(.badServerResponse))
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
            let decoded = try decoder.decode(AirQualityResponse.self, from: data)
            return mapResponse(decoded)
        } catch {
            throw WeatherProviderError.decodingError(underlying: error)
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
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else {
            throw WeatherProviderError.networkError(underlying: URLError(.badURL))
        }
        return url
    }

    private func mapResponse(_ response: AirQualityResponse) -> AirQuality {
        let current = response.current
        let aqi = current.europeanAqi ?? current.usAqi ?? 0
        let category: AQICategory = if let eu = current.europeanAqi {
            AQICategory(europeanAQI: eu)
        } else if let us = current.usAqi {
            AQICategory(usAQI: us)
        } else {
            .good
        }

        return AirQuality(
            aqi: aqi,
            aqiCategory: category,
            pm25: current.pm25,
            pm10: current.pm10,
            ozone: current.ozone,
            nitrogenDioxide: current.nitrogenDioxide,
            sulphurDioxide: current.sulphurDioxide,
            carbonMonoxide: current.carbonMonoxide,
            timestamp: current.time
        )
    }
}

// MARK: - Response Models

private struct AirQualityResponse: Decodable {
    let current: AirQualityCurrent
}

private struct AirQualityCurrent: Decodable {
    let time: Date
    let europeanAqi: Int?
    let usAqi: Int?
    let pm25: Double
    let pm10: Double
    let ozone: Double?
    let nitrogenDioxide: Double?
    let sulphurDioxide: Double?
    let carbonMonoxide: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case europeanAqi = "european_aqi"
        case usAqi = "us_aqi"
        case pm25 = "pm2_5"
        case pm10
        case ozone
        case nitrogenDioxide = "nitrogen_dioxide"
        case sulphurDioxide = "sulphur_dioxide"
        case carbonMonoxide = "carbon_monoxide"
    }
}
