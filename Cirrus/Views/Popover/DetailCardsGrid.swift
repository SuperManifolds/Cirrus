import SwiftUI

struct DetailCardsGrid: View {
    let cards: [any WeatherCard]

    var body: some View {
        let visible = cards.filter(\.isRelevant)
        let rows = stride(from: 0, to: visible.count, by: 2).map { idx in
            (visible[idx], idx + 1 < visible.count ? visible[idx + 1] : nil)
        }
        Grid(horizontalSpacing: LayoutConstants.Spacing.cardGrid, verticalSpacing: LayoutConstants.Spacing.cardGrid) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    WeatherDetailCard(
                        title: row.0.title,
                        value: row.0.value,
                        icon: row.0.icon,
                        iconColor: row.0.iconColor
                    )
                    if let second = row.1 {
                        WeatherDetailCard(
                            title: second.title,
                            value: second.value,
                            icon: second.icon,
                            iconColor: second.iconColor
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    let current = CurrentWeather(
        temperature: Measurement(value: 22, unit: .celsius),
        apparentTemperature: Measurement(value: 20, unit: .celsius),
        dewPoint: Measurement(value: 18, unit: .celsius),
        condition: .partlyCloudy,
        humidity: 75,
        windSpeed: Measurement(value: 12, unit: .kilometersPerHour),
        windDirection: 225,
        windGusts: nil,
        pressure: Measurement(value: 998, unit: .hectopascals),
        uvIndex: 5,
        cloudCover: 40,
        visibility: Measurement(value: 5000, unit: .meters),
        precipitation: Measurement(value: 0, unit: .millimeters),
        rain: nil, snowfall: nil, snowDepth: nil,
        isDaytime: true,
        timestamp: Date()
    )
    DetailCardsGrid(cards: [
        WindCard(current: current),
        HumidityCard(current: current),
        UVIndexCard(current: current),
        PressureCard(current: current),
        CloudCoverCard(current: current),
        VisibilityCard(current: current)
    ])
    .frame(width: 320)
    .padding()
}
#endif
