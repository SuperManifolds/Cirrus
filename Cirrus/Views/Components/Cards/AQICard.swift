import SwiftUI

struct AQICard: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "aqi" }
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
