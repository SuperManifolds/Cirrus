import SwiftUI

enum CardVisualPlacement {
    case inline
    case fullWidth
}

protocol WeatherCard {
    var title: String { get }
    var value: String { get }
    var icon: String { get }
    var iconColor: Color { get }
    var isRelevant: Bool { get }
    var directionDegrees: Double? { get }
    var trendValues: [Double]? { get }
    var trendColor: Color? { get }
    var customVisual: AnyView? { get }
    var visualPlacement: CardVisualPlacement { get }
}

extension WeatherCard {
    var directionDegrees: Double? { nil }
    var trendValues: [Double]? { nil }
    var trendColor: Color? { nil }
    var customVisual: AnyView? { nil }
    var visualPlacement: CardVisualPlacement { .inline }
}

// MARK: - Card Implementations

struct WindCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var title: String { String(localized: "Wind") }
    var icon: String { "wind" }
    var iconColor: Color { .teal }
    var isRelevant: Bool { current.windSpeed.converted(to: .kilometersPerHour).value >= 1 }
    var value: String {
        "\(current.windSpeed.formattedWindSpeed) \(compassDirection(from: current.windDirection))"
    }
    var directionDegrees: Double? { current.windDirection }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).map { $0.windSpeed.converted(to: .kilometersPerHour).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .teal }
}

struct HumidityCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var title: String { String(localized: "Humidity") }
    var icon: String { "humidity.fill" }
    var iconColor: Color { .cyan }
    var isRelevant: Bool { current.humidity < 30 || current.humidity > 70 }
    var value: String { "\(Int(current.humidity))%" }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).map(\.humidity)
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .cyan }
}

struct UVIndexCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var title: String { String(localized: "UV Index") }
    var icon: String { "sun.max.fill" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { current.isDaytime && current.uvIndex >= 3 }
    var value: String { "\(Int(current.uvIndex)) · \(uvDescription)" }
    var customVisual: AnyView? {
        AnyView(
            UVSeverityBar(uvIndex: current.uvIndex)
                .frame(height: 4)
        )
    }
    var visualPlacement: CardVisualPlacement { .fullWidth }

    private var uvDescription: String {
        switch Int(current.uvIndex) {
            case 0...2: return String(localized: "Low")
            case 3...5: return String(localized: "Moderate")
            case 6...7: return String(localized: "High")
            case 8...10: return String(localized: "Very High")
            default: return String(localized: "Extreme")
        }
    }
}

struct PressureCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var title: String { String(localized: "Pressure") }
    var icon: String { "gauge.medium" }
    var iconColor: Color { .purple }
    var isRelevant: Bool {
        let hPa = Int(current.pressure.converted(to: .hectopascals).value)
        return hPa < 1000 || hPa > 1025
    }
    var value: String {
        let formatted = current.pressure.formattedPressure
        guard let trend = pressureTrend else { return formatted }
        return "\(formatted) \(trend)"
    }

    private var pressureTrend: String? {
        let values = hourly.prefix(4).compactMap { $0.pressure?.converted(to: .hectopascals).value }
        guard values.count >= 2 else { return nil }
        let first = values.first ?? 0
        let last = values.last ?? 0
        let delta = last - first
        if delta > 1 { return "↑" }
        if delta < -1 { return "↓" }
        return "→"
    }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap { $0.pressure?.converted(to: .hectopascals).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .purple }
}

struct CloudCoverCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var title: String { String(localized: "Cloud Cover") }
    var icon: String { "cloud.fill" }
    var iconColor: Color { .gray }
    var isRelevant: Bool { current.cloudCover > 0 }
    var value: String { "\(Int(current.cloudCover))%" }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap(\.cloudCover)
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .gray }
}

struct VisibilityCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
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
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap { $0.visibility?.converted(to: .kilometers).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .mint }
}

struct DewPointCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
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
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap { $0.dewPoint?.converted(to: .celsius).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .teal }
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
    var customVisual: AnyView? {
        guard let depth = current.snowDepth else { return nil }
        let cm = depth.converted(to: .centimeters).value
        return AnyView(
            DepthBarView(depth: cm, maxDepth: 50)
                .frame(width: LayoutConstants.Size.depthBarWidth, height: LayoutConstants.Size.depthBarHeight)
        )
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
    var customVisual: AnyView? {
        guard let sunrise = today?.sunrise, let sunset = today?.sunset else { return nil }
        return AnyView(
            DayArcView(sunrise: sunrise, sunset: sunset, now: Date())
                .frame(width: LayoutConstants.Size.dayArcWidth, height: LayoutConstants.Size.dayArcHeight)
        )
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
    var customVisual: AnyView? {
        guard let sunrise = today?.sunrise, let sunset = today?.sunset else { return nil }
        return AnyView(
            DayArcView(sunrise: sunrise, sunset: sunset, now: Date())
                .frame(width: LayoutConstants.Size.dayArcWidth, height: LayoutConstants.Size.dayArcHeight)
        )
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
    var customVisual: AnyView? {
        guard let aq = airQuality else { return nil }
        return AnyView(
            GaugeArcView(
                value: Double(aq.aqi), maxValue: 100,
                colors: [.green, .yellow, .orange, .red, .purple]
            )
            .frame(width: LayoutConstants.Size.gaugeArcWidth, height: LayoutConstants.Size.gaugeArcHeight)
        )
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
    var customVisual: AnyView? {
        guard let aq = airQuality else { return nil }
        return AnyView(
            GaugeArcView(
                value: aq.pm25, maxValue: 75,
                colors: [.green, .yellow, .orange, .red]
            )
            .frame(width: LayoutConstants.Size.gaugeArcWidth, height: LayoutConstants.Size.gaugeArcHeight)
        )
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
    var customVisual: AnyView? {
        guard let aq = airQuality else { return nil }
        return AnyView(
            GaugeArcView(
                value: aq.pm10, maxValue: 150,
                colors: [.green, .yellow, .orange, .red]
            )
            .frame(width: LayoutConstants.Size.gaugeArcWidth, height: LayoutConstants.Size.gaugeArcHeight)
        )
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
    var customVisual: AnyView? {
        guard let grains else { return nil }
        let level = PollenLevel(grainsPerM3: grains)
        let levelInt: Int = switch level {
            case .low: 1
            case .moderate: 2
            case .high: 3
            case .veryHigh: 4
        }
        return AnyView(
            SeverityDotsView(level: levelInt, maxLevel: 4, activeColor: pollenColor)
        )
    }
}
