import Foundation

struct CurrentWeather: Sendable {
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let humidity: Double
    let windSpeed: Measurement<UnitSpeed>
    let windDirection: Double
    let windGusts: Measurement<UnitSpeed>?
    let pressure: Measurement<UnitPressure>
    let uvIndex: Double
    let cloudCover: Double
    let precipitation: Measurement<UnitLength>
    let isDaytime: Bool
    let timestamp: Date
}
