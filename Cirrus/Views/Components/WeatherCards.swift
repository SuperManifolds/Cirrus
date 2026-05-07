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
        "\(current.windSpeed.formattedWindSpeed) \(compassDirection(from: current.windDirection))"
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
    var isRelevant: Bool { current.isDaytime && current.uvIndex >= 3 }
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
    var value: String { current.pressure.formattedPressure }
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
        current.visibility?.formattedVisibility ?? ""
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
        current.snowDepth?.formattedSnowDepth ?? ""
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
        return sunrise.formatted(date: .omitted, time: .shortened)
    }
}

struct SunsetCard: WeatherCard {
    let today: DailyForecast?
    var title: String { String(localized: "Sunset") }
    var icon: String { "sunset.fill" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { today?.sunset != nil }
    var value: String {
        guard let sunset = today?.sunset else { return "" }
        return sunset.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Air Quality Cards

struct AQICard: WeatherCard {
    let airQuality: AirQuality?
    var title: String { String(localized: "Air Quality") }
    var icon: String { "aqi.medium" }
    var iconColor: Color { aqiColor }
    var isRelevant: Bool { airQuality != nil }
    var value: String {
        guard let aq = airQuality else { return "" }
        return "\(aq.aqi) · \(aq.aqiCategory.displayName)"
    }
    private var aqiColor: Color {
        guard let aq = airQuality else { return .gray }
        switch aq.aqiCategory {
            case .good: return .green
            case .fair: return .yellow
            case .moderate: return .orange
            case .poor: return .red
            case .veryPoor: return .purple
            case .hazardous: return .red
        }
    }
}

struct PM25Card: WeatherCard {
    let airQuality: AirQuality?
    var title: String { String(localized: "PM2.5") }
    var icon: String { "circle.dotted.circle" }
    var iconColor: Color { .indigo }
    var isRelevant: Bool {
        guard let aq = airQuality else { return false }
        return aq.pm25 >= 10
    }
    var value: String {
        guard let aq = airQuality else { return "" }
        return "\(Int(aq.pm25)) µg/m³"
    }
}

struct PM10Card: WeatherCard {
    let airQuality: AirQuality?
    var title: String { String(localized: "PM10") }
    var icon: String { "circle.dotted.circle" }
    var iconColor: Color { .brown }
    var isRelevant: Bool {
        guard let aq = airQuality else { return false }
        return aq.pm10 >= 20
    }
    var value: String {
        guard let aq = airQuality else { return "" }
        return "\(Int(aq.pm10)) µg/m³"
    }
}

// MARK: - Pollen Cards

struct PollenCard: WeatherCard {
    let name: String
    let grains: Double?
    var title: String { name }
    var icon: String { "leaf.fill" }
    var iconColor: Color { pollenColor }
    var isRelevant: Bool { (grains ?? 0) >= 1 }
    var value: String {
        guard let grains else { return "" }
        let level = PollenLevel(grainsPerM3: grains)
        return "\(Int(grains)) · \(level.displayName)"
    }
    private var pollenColor: Color {
        guard let grains else { return .gray }
        switch PollenLevel(grainsPerM3: grains) {
            case .low: return .green
            case .moderate: return .yellow
            case .high: return .orange
            case .veryHigh: return .red
        }
    }
}
