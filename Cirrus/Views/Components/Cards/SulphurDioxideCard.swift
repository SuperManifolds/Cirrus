import SwiftUI

struct SulphurDioxideCard: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "so2" }
    var title: String { "SO₂" }
    var icon: String { "aqi.low" }
    var iconColor: Color { .yellow }
    var isRelevant: Bool { (airQuality?.sulphurDioxide ?? 0) > 20 }
    var value: String {
        guard let val = airQuality?.sulphurDioxide else { return "" }
        return "\(Int(val)) µg/m³"
    }
}
