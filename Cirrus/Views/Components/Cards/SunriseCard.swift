import SwiftUI

struct SunriseCard: WeatherCard {
    let today: DailyForecast?
    var cardID: String { "sunrise" }
    var title: String { String(localized: "Sunrise") }
    var icon: String { "sunrise.fill" }
    var iconColor: Color { .yellow }
    var isRelevant: Bool { today?.sunrise != nil }
    var value: String {
        guard let sunrise = today?.sunrise else { return "" }
        return sunrise.formatted(date: .omitted, time: .shortened)
    }
    var customVisual: AnyView? {
        guard let sunrise = today?.sunrise, let sunset = today?.sunset else { return nil }
        return AnyView(
            DayArcView(sunrise: sunrise, sunset: sunset, now: Date())
                .frame(width: LayoutConstants.Size.dayArcWidth, height: LayoutConstants.Size.dayArcHeight)
        )
    }
}
