import SwiftUI

struct CloudCoverCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "cloudCover" }
    var title: String { String(localized: "Cloud Cover") }
    var icon: String { "cloud.fill" }
    var iconColor: Color { .gray }
    var isRelevant: Bool { current.cloudCover > 0 }
    var value: String { "\(Int(current.cloudCover))%" }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap(\.cloudCover)
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .gray }
}
