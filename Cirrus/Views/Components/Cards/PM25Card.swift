import SwiftUI

struct PM25Card: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "pm25" }
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
