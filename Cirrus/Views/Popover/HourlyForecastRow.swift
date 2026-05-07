import SwiftUI

struct HourlyForecastRow: View {
    let forecast: HourlyForecast
    let unit: TemperatureUnit
    let isNow: Bool

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 6) {
            Text(isNow ? String(localized: "Now") : Self.hourFormatter.string(from: forecast.date))
                .font(.caption2)
                .foregroundStyle(isNow ? .primary : .secondary)

            WeatherIcon(condition: forecast.condition, isDaytime: forecast.isDaytime, size: 18)

            TemperatureText(measurement: forecast.temperature, unit: unit, font: .caption)

            Text(forecast.precipitationProbability > 0 ? "\(Int(forecast.precipitationProbability))%" : "")
                .font(.caption2)
                .foregroundStyle(.cyan)
        }
        .frame(width: 44)
    }
}

#if DEBUG
#Preview {
    HStack {
        HourlyForecastRow(
            forecast: HourlyForecast(
                date: Date(),
                temperature: Measurement(value: 22, unit: .celsius),
                apparentTemperature: Measurement(value: 20, unit: .celsius),
                condition: .partlyCloudy,
                precipitationProbability: 30,
                precipitation: Measurement(value: 0.5, unit: .millimeters),
                humidity: 55,
                windSpeed: Measurement(value: 10, unit: .kilometersPerHour),
                isDaytime: true
            ),
            unit: .celsius,
            isNow: true
        )
        HourlyForecastRow(
            forecast: HourlyForecast(
                date: Date().addingTimeInterval(3600),
                temperature: Measurement(value: 19, unit: .celsius),
                apparentTemperature: Measurement(value: 17, unit: .celsius),
                condition: .rain,
                precipitationProbability: 80,
                precipitation: Measurement(value: 2, unit: .millimeters),
                humidity: 70,
                windSpeed: Measurement(value: 15, unit: .kilometersPerHour),
                isDaytime: true
            ),
            unit: .celsius,
            isNow: false
        )
    }
    .padding()
}
#endif
