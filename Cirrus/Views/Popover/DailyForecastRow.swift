import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast
    let unit: TemperatureUnit
    let weekMin: Double
    let weekMax: Double

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private var isToday: Bool {
        Calendar.current.isDateInToday(forecast.date)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(isToday ? String(localized: "Today") : Self.dayFormatter.string(from: forecast.date))
                .font(.callout)
                .frame(width: 44, alignment: .leading)

            WeatherIcon(condition: forecast.condition, isDaytime: true, size: 16)

            if forecast.precipitationProbability > 0 {
                Text("\(Int(forecast.precipitationProbability))%")
                    .font(.caption2)
                    .foregroundStyle(.cyan)
                    .frame(width: 30, alignment: .trailing)
            } else {
                Spacer()
                    .frame(width: 30)
            }

            TemperatureText(measurement: forecast.lowTemperature, unit: unit, font: .caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)

            temperatureBar

            TemperatureText(measurement: forecast.highTemperature, unit: unit, font: .caption)
                .frame(width: 32, alignment: .trailing)
        }
        .padding(.horizontal, 8)
    }

    private var temperatureBar: some View {
        GeometryReader { geometry in
            let range = weekMax - weekMin
            let dayLow = forecast.lowTemperature.converted(to: .celsius).value
            let dayHigh = forecast.highTemperature.converted(to: .celsius).value
            let startFraction = range > 0 ? (dayLow - weekMin) / range : 0
            let endFraction = range > 0 ? (dayHigh - weekMin) / range : 1

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(4, geometry.size.width * (endFraction - startFraction)),
                        height: 4
                    )
                    .offset(x: geometry.size.width * startFraction)
            }
        }
        .frame(height: 4)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 4) {
        DailyForecastRow(
            forecast: DailyForecast(
                date: Date(),
                highTemperature: Measurement(value: 24, unit: .celsius),
                lowTemperature: Measurement(value: 14, unit: .celsius),
                condition: .partlyCloudy,
                precipitationProbability: 20,
                precipitationSum: Measurement(value: 1, unit: .millimeters),
                rainSum: Measurement(value: 1, unit: .millimeters),
                snowfallSum: nil,
                uvIndexMax: 6,
                windSpeedMax: Measurement(value: 20, unit: .kilometersPerHour),
                windDirectionDominant: 180,
                sunrise: nil,
                sunset: nil
            ),
            unit: .celsius,
            weekMin: 10,
            weekMax: 28
        )
    }
    .frame(width: 320)
    .padding()
}
#endif
