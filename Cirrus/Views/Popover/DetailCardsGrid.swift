import SwiftUI

struct DetailCardsGrid: View {
    let cards: [any WeatherCard]
    var hiddenCardIDs: Set<String> = []

    var body: some View {
        let visible = cards.filter { $0.isRelevant && !hiddenCardIDs.contains($0.cardID) }
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
                        iconColor: row.0.iconColor,
                        directionDegrees: row.0.directionDegrees,
                        trendValues: row.0.trendValues,
                        trendColor: row.0.trendColor,
                        customVisual: row.0.customVisual,
                        visualPlacement: row.0.visualPlacement
                    )
                    if let second = row.1 {
                        WeatherDetailCard(
                            title: second.title,
                            value: second.value,
                            icon: second.icon,
                            iconColor: second.iconColor,
                            directionDegrees: second.directionDegrees,
                            trendValues: second.trendValues,
                            trendColor: second.trendColor,
                            customVisual: second.customVisual,
                            visualPlacement: second.visualPlacement
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
    let hourly = MockWeatherProvider.mockHourly()
    DetailCardsGrid(cards: [
        WindCard(current: current, hourly: hourly),
        HumidityCard(current: current, hourly: hourly),
        UVIndexCard(current: current, hourly: hourly),
        PressureCard(current: current, hourly: hourly),
        CloudCoverCard(current: current, hourly: hourly),
        VisibilityCard(current: current, hourly: hourly)
    ])
    .frame(width: 320)
    .padding()
}
#endif
