import SwiftUI

struct CurrentConditionsView: View {
    let current: CurrentWeather
    let today: DailyForecast?
    let locationName: String
    let unit: TemperatureUnit

    var body: some View {
        VStack(spacing: 10) {
            Text(locationName)
                .font(.headline)
                .padding(.bottom, 2)

            HStack(spacing: 8) {
                WeatherIcon(condition: current.condition, isDaytime: current.isDaytime, size: 36)

                TemperatureText(
                    measurement: current.temperature,
                    unit: unit,
                    font: .system(size: 34, weight: .light)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(current.condition.displayName)
                        .font(.subheadline)

                    let feelsLike = current.apparentTemperature.formatted(as: unit)
                    Text(String(localized: "Feels like \(feelsLike)"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 2)

            detailCards
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
    }

    private var allCards: [any WeatherCard] {
        [
            WindCard(current: current),
            HumidityCard(current: current),
            UVIndexCard(current: current),
            PressureCard(current: current),
            CloudCoverCard(current: current),
            VisibilityCard(current: current),
            DewPointCard(current: current, unit: unit),
            SnowDepthCard(current: current),
            SunriseCard(today: today),
            SunsetCard(today: today)
        ]
    }

    private var detailCards: some View {
        let visible = allCards.filter(\.isRelevant)
        let rows = stride(from: 0, to: visible.count, by: 2).map { idx in
            (visible[idx], idx + 1 < visible.count ? visible[idx + 1] : nil)
        }
        return Grid(horizontalSpacing: 6, verticalSpacing: 6) {
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
    CurrentConditionsView(
        current: CurrentWeather(
            temperature: Measurement(value: 22, unit: .celsius),
            apparentTemperature: Measurement(value: 20, unit: .celsius),
            dewPoint: Measurement(value: 12, unit: .celsius),
            condition: .partlyCloudy,
            humidity: 55,
            windSpeed: Measurement(value: 12, unit: .kilometersPerHour),
            windDirection: 225,
            windGusts: Measurement(value: 25, unit: .kilometersPerHour),
            pressure: Measurement(value: 1013, unit: .hectopascals),
            uvIndex: 5,
            cloudCover: 40,
            visibility: Measurement(value: 15000, unit: .meters),
            precipitation: Measurement(value: 0, unit: .millimeters),
            rain: Measurement(value: 0, unit: .millimeters),
            snowfall: nil,
            snowDepth: Measurement(value: 0.15, unit: .meters),
            isDaytime: true,
            timestamp: Date()
        ),
        today: DailyForecast(
            date: Date(),
            highTemperature: Measurement(value: 24, unit: .celsius),
            lowTemperature: Measurement(value: 14, unit: .celsius),
            condition: .partlyCloudy,
            precipitationProbability: 30,
            precipitationSum: Measurement(value: 2, unit: .millimeters),
            rainSum: Measurement(value: 1.5, unit: .millimeters),
            snowfallSum: Measurement(value: 0.5, unit: .centimeters),
            uvIndexMax: 6,
            windSpeedMax: Measurement(value: 20, unit: .kilometersPerHour),
            windDirectionDominant: 225,
            sunrise: Calendar.current.date(bySettingHour: 5, minute: 17, second: 0, of: Date()),
            sunset: Calendar.current.date(bySettingHour: 21, minute: 42, second: 0, of: Date())
        ),
        locationName: "Oslo",
        unit: .celsius
    )
    .frame(width: 320)
}
#endif
