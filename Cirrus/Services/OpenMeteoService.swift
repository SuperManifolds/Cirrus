import Foundation
import OSLog

struct OpenMeteoService: WeatherProviding {
    let kind: WeatherProviderKind = .openMeteo
    private let session: URLSession
    private let nowcastService: METNorwayNowcastService

    init(session: URLSession = .shared) {
        self.session = session
        self.nowcastService = METNorwayNowcastService(session: session)
    }

    private static let baseURL = "https://api.open-meteo.com/v1/forecast"

    private static let currentParams = [
        "temperature_2m", "relative_humidity_2m", "apparent_temperature",
        "dew_point_2m", "weather_code", "wind_speed_10m", "wind_direction_10m",
        "wind_gusts_10m", "precipitation", "rain", "snowfall", "snow_depth",
        "cloud_cover", "pressure_msl", "uv_index", "visibility", "is_day"
    ].joined(separator: ",")

    private static let hourlyParams = [
        "temperature_2m", "relative_humidity_2m", "apparent_temperature",
        "weather_code", "precipitation_probability", "precipitation",
        "wind_speed_10m", "cloud_cover", "visibility", "dew_point_2m",
        "pressure_msl", "uv_index", "is_day"
    ].joined(separator: ",")

    private static let dailyParams = [
        "temperature_2m_max", "temperature_2m_min", "weather_code",
        "precipitation_probability_max", "precipitation_sum",
        "rain_sum", "snowfall_sum",
        "uv_index_max", "wind_speed_10m_max", "wind_direction_10m_dominant",
        "sunrise", "sunset"
    ].joined(separator: ",")

    private static let minutely15Params = "precipitation"

    func fetchWeather(for location: Location) async throws -> WeatherSnapshot {
        let url = try buildURL(for: location)
        Log.api.debug("Fetching Open-Meteo: \(url)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherProviderError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherProviderError.networkError(underlying: URLError(.badServerResponse))
        }

        if httpResponse.statusCode == 429 {
            throw WeatherProviderError.rateLimited
        }

        guard httpResponse.statusCode == 200 else {
            throw WeatherProviderError.networkError(underlying: URLError(.badServerResponse))
        }

        let decoded: OpenMeteoResponse
        do {
            // First pass: extract timezone from response
            let meta = try JSONDecoder().decode(OpenMeteoTimezone.self, from: data)
            let tz = TimeZone(identifier: meta.timezone) ?? .current

            // Second pass: decode full response with correct timezone
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                try Self.decodeOpenMeteoDate(decoder: decoder, timeZone: tz)
            }
            decoded = try decoder.decode(OpenMeteoResponse.self, from: data)
        } catch {
            throw WeatherProviderError.decodingError(underlying: error)
        }

        // MET Norway nowcast provides 5-min radar precipitation for Nordic countries.
        // Falls back to Open-Meteo's interpolated minutely_15 data elsewhere.
        let nowcast = try? await nowcastService.fetchNowcast(for: location)
        Log.api.debug("Nowcast: \(nowcast?.count ?? -1) entries, minutely_15: \(decoded.minutely15?.time.count ?? -1) entries")

        return mapToSnapshot(decoded, location: location, nowcast: nowcast)
    }

    private func buildURL(for location: Location) throws -> URL {
        guard var components = URLComponents(string: Self.baseURL) else {
            throw WeatherProviderError.networkError(underlying: URLError(.badURL))
        }
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "current", value: Self.currentParams),
            URLQueryItem(name: "hourly", value: Self.hourlyParams),
            URLQueryItem(name: "daily", value: Self.dailyParams),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "10"),
            URLQueryItem(name: "forecast_hours", value: "24"),
            URLQueryItem(name: "minutely_15", value: Self.minutely15Params),
            URLQueryItem(name: "forecast_minutely_15", value: "4")
        ]
        guard let url = components.url else {
            throw WeatherProviderError.networkError(underlying: URLError(.badURL))
        }
        return url
    }

    private func mapToSnapshot(
        _ response: OpenMeteoResponse,
        location: Location,
        nowcast: [MinuteForecast]?
    ) -> WeatherSnapshot {
        let current = mapCurrent(response.current)
        let hourly = mapHourly(response.hourly)
        let daily = mapDaily(response.daily)
        let minutely = nowcast ?? mapMinutely(response.minutely15)
        return WeatherSnapshot(
            current: current, hourly: hourly, daily: daily, minutely: minutely,
            alerts: [], location: location, fetchedAt: Date(), provider: .openMeteo
        )
    }

    private func mapCurrent(_ om: OpenMeteoCurrent) -> CurrentWeather {
        CurrentWeather(
            temperature: Measurement(value: om.temperature2m, unit: .celsius),
            apparentTemperature: Measurement(value: om.apparentTemperature, unit: .celsius),
            dewPoint: Measurement(value: om.dewPoint2m, unit: .celsius),
            condition: WeatherCondition(wmoCode: om.weatherCode),
            humidity: om.relativeHumidity2m,
            windSpeed: Measurement(value: om.windSpeed10m, unit: .kilometersPerHour),
            windDirection: om.windDirection10m,
            windGusts: Measurement(value: om.windGusts10m, unit: .kilometersPerHour),
            pressure: Measurement(value: om.pressureMsl, unit: .hectopascals),
            uvIndex: om.uvIndex,
            cloudCover: om.cloudCover,
            visibility: Measurement(value: om.visibility, unit: .meters),
            precipitation: Measurement(value: om.precipitation, unit: .millimeters),
            rain: Measurement(value: om.rain, unit: .millimeters),
            snowfall: Measurement(value: om.snowfall, unit: .centimeters),
            snowDepth: Measurement(value: om.snowDepth, unit: .meters),
            isDaytime: om.isDay == 1,
            timestamp: om.time
        )
    }

    private func mapHourly(_ om: OpenMeteoHourly) -> [HourlyForecast] {
        let count = om.time.count
        var results: [HourlyForecast] = []
        results.reserveCapacity(count)
        for idx in 0..<count {
            let temp: Measurement<UnitTemperature> = Measurement(value: om.temperature2m[idx], unit: .celsius)
            let apparent: Measurement<UnitTemperature> = Measurement(value: om.apparentTemperature[idx], unit: .celsius)
            let wind: Measurement<UnitSpeed> = Measurement(value: om.windSpeed10m[idx], unit: .kilometersPerHour)
            let precip: Measurement<UnitLength> = Measurement(value: om.precipitation[idx], unit: .millimeters)
            let dp: Measurement<UnitTemperature> = Measurement(value: om.dewPoint2m[idx], unit: .celsius)
            let pres: Measurement<UnitPressure> = Measurement(value: om.pressureMsl[idx], unit: .hectopascals)
            let vis: Measurement<UnitLength> = Measurement(value: om.visibility[idx], unit: .meters)
            results.append(HourlyForecast(
                date: om.time[idx],
                temperature: temp,
                apparentTemperature: apparent,
                condition: WeatherCondition(wmoCode: om.weatherCode[idx]),
                precipitationProbability: om.precipitationProbability[idx],
                precipitation: precip,
                humidity: om.relativeHumidity2m[idx],
                windSpeed: wind,
                cloudCover: om.cloudCover[idx],
                visibility: vis,
                dewPoint: dp,
                pressure: pres,
                uvIndex: om.uvIndex[idx],
                isDaytime: om.isDay[idx] == 1
            ))
        }
        return results
    }

    private func mapDaily(_ om: OpenMeteoDaily) -> [DailyForecast] {
        let count = om.time.count
        var results: [DailyForecast] = []
        results.reserveCapacity(count)
        for idx in 0..<count {
            let high: Measurement<UnitTemperature> = Measurement(value: om.temperature2mMax[idx], unit: .celsius)
            let low: Measurement<UnitTemperature> = Measurement(value: om.temperature2mMin[idx], unit: .celsius)
            let precipSum: Measurement<UnitLength> = Measurement(value: om.precipitationSum[idx], unit: .millimeters)
            let wind: Measurement<UnitSpeed> = Measurement(value: om.windSpeed10mMax[idx], unit: .kilometersPerHour)
            let rainSum: Measurement<UnitLength> = Measurement(value: om.rainSum[idx], unit: .millimeters)
            let snowSum: Measurement<UnitLength> = Measurement(value: om.snowfallSum[idx], unit: .centimeters)
            results.append(DailyForecast(
                date: om.time[idx],
                highTemperature: high,
                lowTemperature: low,
                condition: WeatherCondition(wmoCode: om.weatherCode[idx]),
                precipitationProbability: om.precipitationProbabilityMax[idx],
                precipitationSum: precipSum,
                rainSum: rainSum,
                snowfallSum: snowSum,
                uvIndexMax: om.uvIndexMax[idx],
                windSpeedMax: wind,
                windDirectionDominant: om.windDirection10mDominant[idx],
                sunrise: om.sunrise[idx],
                sunset: om.sunset[idx]
            ))
        }
        return results
    }

    private func mapMinutely(_ om: OpenMeteoMinutely15?) -> [MinuteForecast]? {
        guard let om else { return nil }
        let count = om.time.count
        guard count > 0 else { return nil }
        var results: [MinuteForecast] = []
        results.reserveCapacity(count)
        for idx in 0..<count {
            results.append(MinuteForecast(
                date: om.time[idx],
                precipitationIntensity: om.precipitation[idx],
                precipitationChance: om.precipitation[idx] > 0 ? 100 : 0,
                precipitationType: nil
            ))
        }
        return results
    }

    private static func decodeOpenMeteoDate(decoder: Decoder, timeZone: TimeZone) throws -> Date {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        let dtFormatter = DateFormatter()
        dtFormatter.locale = Locale(identifier: "en_US_POSIX")
        dtFormatter.timeZone = timeZone

        dtFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        if let date = dtFormatter.date(from: string) {
            return date
        }

        dtFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dtFormatter.date(from: string) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date: \(string)"
        )
    }
}

// MARK: - Response Models

private struct OpenMeteoTimezone: Decodable {
    let timezone: String
}

private struct OpenMeteoResponse: Decodable {
    let current: OpenMeteoCurrent
    let hourly: OpenMeteoHourly
    let daily: OpenMeteoDaily
    let minutely15: OpenMeteoMinutely15?

    enum CodingKeys: String, CodingKey {
        case current, hourly, daily
        case minutely15 = "minutely_15"
    }
}

private struct OpenMeteoCurrent: Decodable {
    let time: Date
    let temperature2m: Double
    let relativeHumidity2m: Double
    let apparentTemperature: Double
    let dewPoint2m: Double
    let weatherCode: Int
    let windSpeed10m: Double
    let windDirection10m: Double
    let windGusts10m: Double
    let precipitation: Double
    let rain: Double
    let snowfall: Double
    let snowDepth: Double
    let cloudCover: Double
    let pressureMsl: Double
    let uvIndex: Double
    let visibility: Double
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case dewPoint2m = "dew_point_2m"
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case windGusts10m = "wind_gusts_10m"
        case precipitation, rain, snowfall
        case snowDepth = "snow_depth"
        case cloudCover = "cloud_cover"
        case pressureMsl = "pressure_msl"
        case uvIndex = "uv_index"
        case visibility
        case isDay = "is_day"
    }
}

private struct OpenMeteoHourly: Decodable {
    let time: [Date]
    let temperature2m: [Double]
    let relativeHumidity2m: [Double]
    let apparentTemperature: [Double]
    let weatherCode: [Int]
    let precipitationProbability: [Double]
    let precipitation: [Double]
    let windSpeed10m: [Double]
    let cloudCover: [Double]
    let visibility: [Double]
    let dewPoint2m: [Double]
    let pressureMsl: [Double]
    let uvIndex: [Double]
    let isDay: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case weatherCode = "weather_code"
        case precipitationProbability = "precipitation_probability"
        case precipitation
        case windSpeed10m = "wind_speed_10m"
        case cloudCover = "cloud_cover"
        case visibility
        case dewPoint2m = "dew_point_2m"
        case pressureMsl = "pressure_msl"
        case uvIndex = "uv_index"
        case isDay = "is_day"
    }
}

private struct OpenMeteoDaily: Decodable {
    let time: [Date]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let weatherCode: [Int]
    let precipitationProbabilityMax: [Double]
    let precipitationSum: [Double]
    let rainSum: [Double]
    let snowfallSum: [Double]
    let uvIndexMax: [Double]
    let windSpeed10mMax: [Double]
    let windDirection10mDominant: [Double]
    let sunrise: [Date?]
    let sunset: [Date?]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case weatherCode = "weather_code"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case precipitationSum = "precipitation_sum"
        case rainSum = "rain_sum"
        case snowfallSum = "snowfall_sum"
        case uvIndexMax = "uv_index_max"
        case windSpeed10mMax = "wind_speed_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case sunrise, sunset
    }
}

private struct OpenMeteoMinutely15: Decodable {
    let time: [Date]
    let precipitation: [Double]
}
