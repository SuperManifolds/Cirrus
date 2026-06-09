import SwiftUI

struct UVIndexCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "uvIndex" }
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
