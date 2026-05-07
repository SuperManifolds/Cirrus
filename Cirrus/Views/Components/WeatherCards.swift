import SwiftUI

protocol WeatherCard {
    var title: String { get }
    var value: String { get }
    var icon: String { get }
    var iconColor: Color { get }
    var isRelevant: Bool { get }
}

// MARK: - Card Implementations

struct WindCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Wind") }
    var icon: String { "wind" }
    var iconColor: Color { .teal }
    var isRelevant: Bool { current.windSpeed.converted(to: .kilometersPerHour).value >= 1 }
    var value: String {
        let speed = current.windSpeed.formattedKmh
        let dir = compassDirection(from: current.windDirection)
        return "\(speed) \(dir)"
    }
}

struct HumidityCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Humidity") }
    var icon: String { "humidity.fill" }
    var iconColor: Color { .cyan }
    var isRelevant: Bool { current.humidity < 30 || current.humidity > 70 }
    var value: String { "\(Int(current.humidity))%" }
}

struct UVIndexCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "UV Index") }
    var icon: String { "sun.max.fill" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { current.isDaytime && current.uvIndex >= 1 }
    var value: String { "\(Int(current.uvIndex))" }
}

struct PressureCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Pressure") }
    var icon: String { "gauge.medium" }
    var iconColor: Color { .purple }
    var isRelevant: Bool {
        let hPa = Int(current.pressure.converted(to: .hectopascals).value)
        return hPa < 1000 || hPa > 1025
    }
    var value: String {
        "\(Int(current.pressure.converted(to: .hectopascals).value)) hPa"
    }
}

struct CloudCoverCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Cloud Cover") }
    var icon: String { "cloud.fill" }
    var iconColor: Color { .gray }
    var isRelevant: Bool { current.cloudCover > 0 }
    var value: String { "\(Int(current.cloudCover))%" }
}

struct VisibilityCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Visibility") }
    var icon: String { "eye.fill" }
    var iconColor: Color { .mint }
    var isRelevant: Bool {
        guard let visibility = current.visibility else { return false }
        return visibility.converted(to: .kilometers).value < 10
    }
    var value: String {
        guard let visibility = current.visibility else { return "" }
        let km = visibility.converted(to: .kilometers).value
        return km >= 1 ? "\(Int(km)) km" : String(format: "%.1f km", km)
    }
}

struct DewPointCard: WeatherCard {
    let current: CurrentWeather
    let unit: TemperatureUnit
    var title: String { String(localized: "Dew Point") }
    var icon: String { "drop.degreesign.fill" }
    var iconColor: Color { .teal }
    var isRelevant: Bool {
        guard let dp = current.dewPoint else { return false }
        let celsius = dp.converted(to: .celsius).value
        return celsius >= 16 || celsius <= -5
    }
    var value: String { current.dewPoint?.formatted(as: unit) ?? "" }
}

struct SnowDepthCard: WeatherCard {
    let current: CurrentWeather
    var title: String { String(localized: "Snow Depth") }
    var icon: String { "snowflake" }
    var iconColor: Color { .blue }
    var isRelevant: Bool {
        guard let depth = current.snowDepth else { return false }
        return depth.converted(to: .centimeters).value >= 1
    }
    var value: String {
        guard let depth = current.snowDepth else { return "" }
        return "\(Int(depth.converted(to: .centimeters).value)) cm"
    }
}

struct SunriseCard: WeatherCard {
    let today: DailyForecast?
    var title: String { String(localized: "Sunrise") }
    var icon: String { "sunrise.fill" }
    var iconColor: Color { .yellow }
    var isRelevant: Bool { today?.sunrise != nil }
    var value: String {
        guard let sunrise = today?.sunrise else { return "" }
        return Self.formatter.string(from: sunrise)
    }
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct SunsetCard: WeatherCard {
    let today: DailyForecast?
    var title: String { String(localized: "Sunset") }
    var icon: String { "sunset.fill" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { today?.sunset != nil }
    var value: String {
        guard let sunset = today?.sunset else { return "" }
        return Self.formatter.string(from: sunset)
    }
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
