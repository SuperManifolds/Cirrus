import Foundation

struct HourlyForecast: Sendable, Codable, Identifiable {
    let date: Date
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let precipitationProbability: Double
    let precipitation: Measurement<UnitLength>
    let humidity: Double
    let windSpeed: Measurement<UnitSpeed>
    let cloudCover: Double?
    let visibility: Measurement<UnitLength>?
    let dewPoint: Measurement<UnitTemperature>?
    let pressure: Measurement<UnitPressure>?
    let uvIndex: Double?
    let isDaytime: Bool

    var id: Date { date }
}
