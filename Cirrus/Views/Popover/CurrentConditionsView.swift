import SwiftUI

struct CurrentConditionsView: View {
    let current: CurrentWeather
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

    private var detailCards: some View {
        let windValue = current.windSpeed.formattedKmh
        let humidityValue = "\(Int(current.humidity))%"
        let uvValue = "\(Int(current.uvIndex))"
        let pressureValue = "\(Int(current.pressure.converted(to: .hectopascals).value)) hPa"

        return Grid(horizontalSpacing: 6, verticalSpacing: 6) {
            GridRow {
                WeatherDetailCard(
                    title: String(localized: "Wind"),
                    value: windValue,
                    icon: "wind"
                )
                WeatherDetailCard(
                    title: String(localized: "Humidity"),
                    value: humidityValue,
                    icon: "humidity.fill"
                )
            }
            GridRow {
                WeatherDetailCard(
                    title: String(localized: "UV Index"),
                    value: uvValue,
                    icon: "sun.max.fill"
                )
                WeatherDetailCard(
                    title: String(localized: "Pressure"),
                    value: pressureValue,
                    icon: "gauge.medium"
                )
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
            condition: .partlyCloudy,
            humidity: 55,
            windSpeed: Measurement(value: 12, unit: .kilometersPerHour),
            windDirection: 180,
            windGusts: Measurement(value: 25, unit: .kilometersPerHour),
            pressure: Measurement(value: 1013, unit: .hectopascals),
            uvIndex: 5,
            cloudCover: 40,
            precipitation: Measurement(value: 0, unit: .millimeters),
            isDaytime: true,
            timestamp: Date()
        ),
        locationName: "Oslo",
        unit: .celsius
    )
    .frame(width: 320)
}
#endif
