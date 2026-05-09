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
                .frame(height: 14)

            WeatherIcon(
                condition: forecast.condition,
                isDaytime: forecast.isDaytime,
                size: LayoutConstants.Size.hourlyIcon
            )
            .frame(height: LayoutConstants.Size.hourlyIcon)

            TemperatureText(measurement: forecast.temperature, unit: unit, font: .caption)
                .frame(height: 14)

            Text(forecast.precipitationProbability > 0 ? "\(Int(forecast.precipitationProbability))%" : " ")
                .font(.caption2)
                .foregroundStyle(precipColor)
                .frame(height: 12)

            precipBar
                .frame(height: 8)
        }
        .frame(width: LayoutConstants.Size.hourlyColumnWidth)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(conditionTint)
        )
    }

    private var isSnowy: Bool {
        switch forecast.condition {
            case .snow, .heavySnow, .snowShowers, .sleet:
                return true
            default:
                return false
        }
    }

    private var precipColor: Color {
        isSnowy ? .white.opacity(0.7) : .cyan
    }

    private var precipBar: some View {
        let mm = forecast.precipitation.converted(to: .millimeters).value
        let fraction = min(mm / 2.0, 1.0)
        return VStack {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 1)
                .fill(mm > 0 ? precipColor : Color.clear)
                .frame(width: 16, height: 8 * fraction)
        }
    }

    private var conditionTint: Color {
        switch forecast.condition {
            case .rain, .heavyRain, .showers, .heavyShowers, .drizzle, .freezingDrizzle, .freezingRain:
                return .cyan.opacity(0.08)
            case .snow, .heavySnow, .snowShowers, .sleet:
                return .white.opacity(0.08)
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
                cloudCover: 40, visibility: nil, dewPoint: nil,
                pressure: nil, uvIndex: 3,
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
                cloudCover: 90, visibility: nil, dewPoint: nil,
                pressure: nil, uvIndex: 1,
                isDaytime: true
            ),
            unit: .celsius,
            isNow: false
        )
        HourlyForecastRow(
            forecast: HourlyForecast(
                date: Date().addingTimeInterval(7200),
                temperature: Measurement(value: -2, unit: .celsius),
                apparentTemperature: Measurement(value: -6, unit: .celsius),
                condition: .snow,
                precipitationProbability: 90,
                precipitation: Measurement(value: 1.5, unit: .millimeters),
                humidity: 85,
                windSpeed: Measurement(value: 20, unit: .kilometersPerHour),
                cloudCover: 100, visibility: nil, dewPoint: nil,
                pressure: nil, uvIndex: 0,
                isDaytime: true
            ),
            unit: .celsius,
            isNow: false
        )
    }
    .padding()
}
#endif
