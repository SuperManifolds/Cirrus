import SwiftUI

struct WindCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "wind" }
    var title: String { String(localized: "Wind") }
    var icon: String { "wind" }
    var iconColor: Color { .mint }
    var isRelevant: Bool { current.windSpeed.converted(to: .kilometersPerHour).value >= 1 }
    var value: String {
        "\(current.windSpeed.formattedWindSpeed) \(compassDirection(from: current.windDirection))"
    }
    var directionDegrees: Double? { current.windDirection }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).map { $0.windSpeed.converted(to: .kilometersPerHour).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .mint }
}
