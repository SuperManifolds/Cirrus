import SwiftUI

struct DewPointCard: WeatherCard {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    let unit: TemperatureUnit
    var cardID: String { "dewPoint" }
    var title: String { String(localized: "Dew Point") }
    var icon: String { "drop.degreesign.fill" }
    var iconColor: Color { .teal }
    var isRelevant: Bool {
        guard let dp = current.dewPoint else { return false }
        let celsius = dp.converted(to: .celsius).value
        return celsius >= 16 || celsius <= -5
    }
    var value: String { current.dewPoint?.formatted(as: unit) ?? "" }
    var trendValues: [Double]? {
        let values = hourly.prefix(8).compactMap { $0.dewPoint?.converted(to: .celsius).value }
        return values.count >= 2 ? values : nil
    }
    var trendColor: Color? { .teal }
}
