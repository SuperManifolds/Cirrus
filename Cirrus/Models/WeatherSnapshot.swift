import Foundation

struct WeatherSnapshot: Sendable, Codable {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    let daily: [DailyForecast]
    let minutely: [MinuteForecast]?
    let alerts: [WeatherAlert]
    let location: Location
    let fetchedAt: Date
    let provider: WeatherProviderKind
    let attributionName: String
    let attributionURL: URL
}

enum WeatherProviderKind: String, Sendable, Codable, CaseIterable, Identifiable {
    case openMeteo = "open_meteo"
    case weatherKit = "weatherkit"

    var id: String { rawValue }
}
