import SwiftUI

struct OzoneCard: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "ozone" }
    var title: String { String(localized: "Ozone") }
    var icon: String { "aqi.low" }
    var iconColor: Color { .blue }
    var isRelevant: Bool { (airQuality?.ozone ?? 0) > 100 }
    var value: String {
        guard let val = airQuality?.ozone else { return "" }
        return "\(Int(val)) µg/m³"
    }
}
