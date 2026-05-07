import Foundation

struct CurrentWeather: Sendable, Codable {
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>
    let dewPoint: Measurement<UnitTemperature>?
    let condition: WeatherCondition
    let humidity: Double
    let windSpeed: Measurement<UnitSpeed>
    let windDirection: Double
    let windGusts: Measurement<UnitSpeed>?
    let pressure: Measurement<UnitPressure>
    let uvIndex: Double
    let cloudCover: Double
    let visibility: Measurement<UnitLength>?
    let precipitation: Measurement<UnitLength>
    let rain: Measurement<UnitLength>?
    let snowfall: Measurement<UnitLength>?
    let snowDepth: Measurement<UnitLength>?
    let isDaytime: Bool
    let timestamp: Date
}
