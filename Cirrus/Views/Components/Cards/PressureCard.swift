import SwiftUI

struct PressureCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "pressure" }
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
