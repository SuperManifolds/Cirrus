import SwiftUI

struct CarbonMonoxideCard: WeatherCard {
    let airQuality: AirQuality?
    var cardID: String { "co" }
    var title: String { "CO" }
    var icon: String { "aqi.low" }
    var iconColor: Color { .red }
    var isRelevant: Bool { (airQuality?.carbonMonoxide ?? 0) > 4000 }
    var value: String {
        guard let val = airQuality?.carbonMonoxide else { return "" }
        return "\(Int(val)) µg/m³"
    }
}
