import SwiftUI

struct VisibilityCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "visibility" }
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
