import SwiftUI

struct NitrogenDioxideCard: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "no2" }
    var title: String { "NO₂" }
    var icon: String { "aqi.low" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { (airQuality?.nitrogenDioxide ?? 0) > 40 }
    var value: String {
        guard let val = airQuality?.nitrogenDioxide else { return "" }
        return "\(Int(val)) µg/m³"
    }
}
