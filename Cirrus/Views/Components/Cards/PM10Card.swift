import SwiftUI

struct PM10Card: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "pm10" }
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
