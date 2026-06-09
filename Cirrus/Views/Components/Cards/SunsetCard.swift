import SwiftUI

struct SunsetCard: WeatherCard {
    let today: DailyForecast?
    var cardID: String { "sunset" }
    var title: String { String(localized: "Sunset") }
    var icon: String { "sunset.fill" }
    var iconColor: Color { .orange }
    var isRelevant: Bool { today?.sunset != nil }
    var value: String {
        guard let sunset = today?.sunset else { return "" }
        return sunset.formatted(date: .omitted, time: .shortened)
    }
    var customVisual: AnyView? {
        guard let sunrise = today?.sunrise, let sunset = today?.sunset else { return nil }
        return AnyView(
            DayArcView(sunrise: sunrise, sunset: sunset, now: Date())
                .frame(width: LayoutConstants.Size.dayArcWidth, height: LayoutConstants.Size.dayArcHeight)
        )
    }
}
