import SwiftUI

struct CurrentConditionsView: View {
    let current: CurrentWeather
    let today: DailyForecast?
    let locationName: String
    let unit: TemperatureUnit

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

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

    private var windValue: String {
        let speed = current.windSpeed.formattedKmh
        let direction = compassDirection(from: current.windDirection)
        return "\(speed) \(direction)"
    }

    private struct CardData: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let icon: String
        let color: Color
    }

    private var cards: [CardData] {
        var result: [CardData] = []

        if current.windSpeed.converted(to: .kilometersPerHour).value >= 1 {
            result.append(CardData(title: String(localized: "Wind"), value: windValue, icon: "wind", color: .teal))
        }
        if current.humidity < 30 || current.humidity > 70 {
            result.append(CardData(
                title: String(localized: "Humidity"),
                value: "\(Int(current.humidity))%",
                icon: "humidity.fill", color: .cyan
            ))
        }

        if current.isDaytime && current.uvIndex >= 1 {
            result.append(CardData(
                title: String(localized: "UV Index"),
                value: "\(Int(current.uvIndex))",
                icon: "sun.max.fill", color: .orange
            ))
        }

        let hPa = Int(current.pressure.converted(to: .hectopascals).value)
        if hPa < 1000 || hPa > 1025 {
            result.append(CardData(
                title: String(localized: "Pressure"),
                value: "\(hPa) hPa",
                icon: "gauge.medium", color: .purple
            ))
        }

        if current.cloudCover > 0 {
            result.append(CardData(
                title: String(localized: "Cloud Cover"),
                value: "\(Int(current.cloudCover))%",
                icon: "cloud.fill", color: .gray
            ))
        }

        if let visibility = current.visibility {
            let km = visibility.converted(to: .kilometers).value
            if km < 10 {
                let formatted = km >= 1 ? "\(Int(km)) km" : String(format: "%.1f km", km)
                result.append(CardData(
                    title: String(localized: "Visibility"),
                    value: formatted, icon: "eye.fill", color: .mint
                ))
            }
        }

        if let dewPoint = current.dewPoint {
            let dpCelsius = dewPoint.converted(to: .celsius).value
            if dpCelsius >= 16 || dpCelsius <= -5 {
                result.append(CardData(
                    title: String(localized: "Dew Point"),
                    value: dewPoint.formatted(as: unit),
                    icon: "drop.degreesign.fill", color: .teal
                ))
            }
        }

        if let snowDepth = current.snowDepth {
            let cm = snowDepth.converted(to: .centimeters).value
            if cm >= 1 {
                result.append(CardData(
                    title: String(localized: "Snow Depth"),
                    value: "\(Int(cm)) cm",
                    icon: "snowflake", color: .blue
                ))
            }
        }

        if let today {
            if let sunrise = today.sunrise {
                result.append(CardData(
                    title: String(localized: "Sunrise"),
                    value: Self.timeFormatter.string(from: sunrise),
                    icon: "sunrise.fill", color: .yellow
                ))
            }
            if let sunset = today.sunset {
                result.append(CardData(
                    title: String(localized: "Sunset"),
                    value: Self.timeFormatter.string(from: sunset),
                    icon: "sunset.fill", color: .orange
                ))
            }
        }

        return result
    }

    private var detailCards: some View {
        let items = cards
        let rows = stride(from: 0, to: items.count, by: 2).map { idx in
            (items[idx], idx + 1 < items.count ? items[idx + 1] : nil)
        }
        return Grid(horizontalSpacing: 6, verticalSpacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    WeatherDetailCard(
                        title: row.0.title,
                        value: row.0.value,
                        icon: row.0.icon,
                        iconColor: row.0.color
                    )
                    if let second = row.1 {
                        WeatherDetailCard(
                            title: second.title,
                            value: second.value,
                            icon: second.icon,
                            iconColor: second.color
                        )
                    }
                }
            }
        }
    }

    private func compassDirection(from degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5).truncatingRemainder(dividingBy: 360) / 45)
        return directions[index]
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
