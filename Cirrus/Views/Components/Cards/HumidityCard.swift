import SwiftUI

struct HumidityCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    var cardID: String { "humidity" }
    var title: String { String(localized: "Humidity") }
    var icon: String { "humidity.fill" }
    var iconColor: Color { .cyan }
    var isRelevant: Bool { current.humidity < 30 || current.humidity > 70 }
    var value: String { "\(Int(current.humidity))%" }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).map(\.humidity)
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .cyan }
}
