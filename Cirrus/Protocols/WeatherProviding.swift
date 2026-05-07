import Foundation

protocol WeatherProviding: Sendable {
    var kind: WeatherProviderKind { get }
    func fetchWeather(for location: Location) async throws -> WeatherSnapshot
}

enum WeatherProviderError: LocalizedError {
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case locationUnavailable
    case providerUnavailable(reason: String)
    case rateLimited

    var errorDescription: String? {
        switch self {
            case .networkError(let error):
                String(localized: "Network error: \(error.localizedDescription)")
            case .decodingError:
                String(localized: "Failed to parse weather data.")
            case .locationUnavailable:
                String(localized: "Location not available.")
            case .providerUnavailable(let reason):
                reason
            case .rateLimited:
                String(localized: "Too many requests. Please wait a moment.")
        }
    }
}

// MARK: - Mock

#if DEBUG
struct MockWeatherProvider: WeatherProviding {
    let kind: WeatherProviderKind = .openMeteo

    func fetchWeather(for location: Location) async throws -> WeatherSnapshot {
        let current = CurrentWeather(
            temperature: Measurement(value: 22, unit: .celsius),
            apparentTemperature: Measurement(value: 20, unit: .celsius),
            condition: .partlyCloudy,
            humidity: 55,
            windSpeed: Measurement(value: 12, unit: .kilometersPerHour),
            windDirection: 180,
            windGusts: Measurement(value: 25, unit: .kilometersPerHour),
            pressure: Measurement(value: 1013, unit: .hectopascals),
            uvIndex: 5,
            cloudCover: 40,
            precipitation: Measurement(value: 0, unit: .millimeters),
            isDaytime: true,
            timestamp: Date()
        )
        let hourly = Self.mockHourly()
        let daily = Self.mockDaily()
        return WeatherSnapshot(
            current: current,
            hourly: hourly,
            daily: daily,
            location: location,
            fetchedAt: Date(),
            provider: .openMeteo
        )
    }

    static func mockHourly() -> [HourlyForecast] {
        let now = Date()
        var results: [HourlyForecast] = []
        for hour in 0..<24 {
            let date = Calendar.current.date(byAdding: .hour, value: hour, to: now) ?? now
            let temp: Measurement<UnitTemperature> = Measurement(value: 18 + Double(hour % 8), unit: .celsius)
            let apparent: Measurement<UnitTemperature> = Measurement(value: 16 + Double(hour % 8), unit: .celsius)
            let condition: WeatherCondition = hour < 6 || hour > 20 ? .clear : .partlyCloudy
            let wind: Measurement<UnitSpeed> = Measurement(value: 10, unit: .kilometersPerHour)
            let precip: Measurement<UnitLength> = Measurement(value: 0, unit: .millimeters)
            results.append(HourlyForecast(
                date: date, temperature: temp, apparentTemperature: apparent,
                condition: condition, precipitationProbability: Double(hour % 4) * 10,
                precipitation: precip, humidity: 50 + Double(hour % 10),
                windSpeed: wind, isDaytime: hour >= 6 && hour <= 20
            ))
        }
        return results
    }

    static func mockDaily() -> [DailyForecast] {
        let conditions: [WeatherCondition] = [.clear, .partlyCloudy, .rain, .cloudy]
        let today = Date()
        var results: [DailyForecast] = []
        for day in 0..<10 {
            let date = Calendar.current.date(byAdding: .day, value: day, to: today) ?? today
            let high: Measurement<UnitTemperature> = Measurement(value: 24 + Double(day % 4), unit: .celsius)
            let low: Measurement<UnitTemperature> = Measurement(value: 14 + Double(day % 3), unit: .celsius)
            let precipSum: Measurement<UnitLength> = Measurement(value: Double(day % 3), unit: .millimeters)
            let wind: Measurement<UnitSpeed> = Measurement(value: 20, unit: .kilometersPerHour)
            results.append(DailyForecast(
                date: date, highTemperature: high, lowTemperature: low,
                condition: conditions[day % conditions.count],
                precipitationProbability: Double(day % 5) * 15,
                precipitationSum: precipSum, uvIndexMax: 6, windSpeedMax: wind,
                sunrise: Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: date),
                sunset: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: date)
            ))
        }
        return results
    }
}
#endif
