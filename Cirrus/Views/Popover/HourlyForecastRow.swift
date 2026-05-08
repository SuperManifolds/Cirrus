import SwiftUI

struct HourlyForecastRow: View {
    let forecast: HourlyForecast
    let unit: TemperatureUnit
    let isNow: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(isNow ? String(localized: "Now") : forecast.date.formatted(.dateTime.hour()))
                .font(.caption2)
                .foregroundStyle(isNow ? .primary : .secondary)

            WeatherIcon(
                condition: forecast.condition,
                isDaytime: forecast.isDaytime,
                size: LayoutConstants.Size.hourlyIcon
            )

            TemperatureText(measurement: forecast.temperature, unit: unit, font: .caption)

            Text(forecast.precipitationProbability > 0 ? "\(Int(forecast.precipitationProbability))%" : "")
                .font(.caption2)
                .foregroundStyle(.cyan)

            precipBar
        }
        .frame(width: LayoutConstants.Size.hourlyColumnWidth)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(conditionTint)
        )
    }

    private var precipBar: some View {
        let mm = forecast.precipitation.converted(to: .millimeters).value
        let height = min(mm / 2.0, 1.0) * 8.0
        return RoundedRectangle(cornerRadius: 1)
            .fill(mm > 0 ? Color.cyan : Color.clear)
            .frame(width: 16, height: max(height, 0))
    }

    private var conditionTint: Color {
        switch forecast.condition {
            case .rain, .heavyRain, .showers, .heavyShowers, .drizzle:
                return .cyan.opacity(0.08)
            case .snow, .heavySnow, .snowShowers, .sleet, .freezingDrizzle, .freezingRain:
                return .blue.opacity(0.06)
            default:
                return .clear
        }
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
