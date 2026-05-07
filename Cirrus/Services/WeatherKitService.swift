import CoreLocation
import Foundation
import WeatherKit

struct WeatherKitService: WeatherProviding {
    let kind: WeatherProviderKind = .weatherKit

    func fetchWeather(for location: Location) async throws -> WeatherSnapshot {
        let service = WeatherService.shared
        let clLocation = location.clLocation

        let currentWeather: WeatherKit.CurrentWeather
        let hourlyForecast: Forecast<HourWeather>
        let dailyForecast: Forecast<DayWeather>
        let minuteForecast: Forecast<MinuteWeather>?
        let weatherAlerts: [WeatherKit.WeatherAlert]?
        do {
            (currentWeather, hourlyForecast, dailyForecast, minuteForecast, weatherAlerts) =
                try await service.weather(
                    for: clLocation,
                    including: .current, .hourly, .daily, .minute, .alerts
                )
        } catch {
            throw WeatherProviderError.networkError(underlying: error)
        }

        let current = mapCurrent(currentWeather)
        let hourly = mapHourly(hourlyForecast)
        let daily = mapDaily(dailyForecast)
        let minutely = mapMinutely(minuteForecast)
        let alerts = mapAlerts(weatherAlerts)

        return WeatherSnapshot(
            current: current, hourly: hourly, daily: daily, minutely: minutely,
            alerts: alerts, location: location, fetchedAt: Date(), provider: .weatherKit
        )
    }

    private func mapCurrent(_ wk: WeatherKit.CurrentWeather) -> CurrentWeather {
        CurrentWeather(
            temperature: wk.temperature,
            apparentTemperature: wk.apparentTemperature,
            dewPoint: wk.dewPoint,
            condition: WeatherCondition(weatherKitCondition: wk.condition),
            humidity: wk.humidity * 100,
            windSpeed: wk.wind.speed,
            windDirection: wk.wind.direction.value,
            windGusts: wk.wind.gust,
            pressure: wk.pressure,
            uvIndex: Double(wk.uvIndex.value),
            cloudCover: wk.cloudCover * 100,
            visibility: wk.visibility,
            precipitation: Measurement(value: 0, unit: .millimeters),
            rain: nil,
            snowfall: nil,
            snowDepth: nil,
            isDaytime: wk.isDaylight,
            timestamp: wk.date
        )
    }

    private func mapHourly(_ forecast: Forecast<HourWeather>) -> [HourlyForecast] {
        Array(forecast.prefix(24)).map { hour in
            HourlyForecast(
                date: hour.date,
                temperature: hour.temperature,
                apparentTemperature: hour.apparentTemperature,
                condition: WeatherCondition(weatherKitCondition: hour.condition),
                precipitationProbability: hour.precipitationChance * 100,
                precipitation: hour.precipitationAmount,
                humidity: hour.humidity * 100,
                windSpeed: hour.wind.speed,
                isDaytime: hour.isDaylight
            )
        }
    }

    private func mapDaily(_ forecast: Forecast<DayWeather>) -> [DailyForecast] {
        Array(forecast.prefix(10)).map { day in
            DailyForecast(
                date: day.date,
                highTemperature: day.highTemperature,
                lowTemperature: day.lowTemperature,
                condition: WeatherCondition(weatherKitCondition: day.condition),
                precipitationProbability: day.precipitationChance * 100,
                precipitationSum: Measurement(value: 0, unit: .millimeters),
                rainSum: nil,
                snowfallSum: nil,
                uvIndexMax: Double(day.uvIndex.value),
                windSpeedMax: day.wind.speed,
                windDirectionDominant: nil,
                sunrise: day.sun.sunrise,
                sunset: day.sun.sunset
            )
        }
    }

    private func mapAlerts(_ alerts: [WeatherKit.WeatherAlert]?) -> [WeatherAlert] {
        guard let alerts else { return [] }
        return alerts.map { alert in
            let severity: AlertSeverity = switch alert.severity {
                case .extreme: .extreme
                case .severe: .severe
                case .moderate: .moderate
                case .minor: .minor
                @unknown default: .unknown
            }
            return WeatherAlert(
                id: UUID().uuidString,
                event: alert.summary,
                severity: severity,
                headline: alert.summary,
                description: alert.detailsURL.absoluteString,
                startDate: alert.metadata.date,
                endDate: alert.metadata.expirationDate,
                source: alert.source
            )
        }
    }

    private func mapMinutely(_ forecast: Forecast<MinuteWeather>?) -> [MinuteForecast]? {
        guard let forecast else { return nil }
        let minutes = Array(forecast.prefix(60))
        guard !minutes.isEmpty else { return nil }
        return minutes.map { minute in
            MinuteForecast(
                date: minute.date,
                precipitationIntensity: minute.precipitationIntensity.value,
                precipitationChance: minute.precipitationChance * 100
            )
        }
    }
}

// MARK: - WeatherCondition mapping

extension WeatherCondition {
    init(weatherKitCondition wk: WeatherKit.WeatherCondition) {
        switch wk {
            case .clear: self = .clear
            case .mostlyClear: self = .mainlyClear
            case .partlyCloudy: self = .partlyCloudy
            case .mostlyCloudy, .cloudy: self = .cloudy
            case .foggy, .haze, .smoky, .blowingDust: self = .fog
            case .drizzle, .sunShowers: self = .drizzle
            case .freezingDrizzle: self = .freezingDrizzle
            case .rain: self = .rain
            case .heavyRain: self = .heavyRain
            case .freezingRain: self = .freezingRain
            case .snow, .flurries, .sunFlurries, .blowingSnow: self = .snow
            case .heavySnow, .blizzard: self = .heavySnow
            case .sleet, .wintryMix: self = .sleet
            case .hail: self = .thunderstormWithHail
            case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms: self = .thunderstorm
            case .tropicalStorm, .hurricane: self = .thunderstorm
            case .frigid, .hot, .breezy, .windy: self = .clear
            @unknown default: self = .cloudy
        }
    }
}
