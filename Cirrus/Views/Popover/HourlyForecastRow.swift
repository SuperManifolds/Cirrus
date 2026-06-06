import SwiftUI

struct HourlyForecastRow: View {
    let forecast: HourlyForecast
    let unit: TemperatureUnit
    let isNow: Bool

    var body: some View {
        VStack(spacing: LayoutConstants.Spacing.hourlyRow) {
            Text(isNow ? String(localized: "Now") : forecast.date.formatted(.dateTime.hour()))
                .font(.caption2)
                .foregroundStyle(isNow ? .primary : .secondary)
                .frame(height: LayoutConstants.Size.hourlyTimeHeight)

            WeatherIcon(
                condition: forecast.condition,
                isDaytime: forecast.isDaytime,
                size: LayoutConstants.Size.hourlyIcon
            )
            .frame(height: LayoutConstants.Size.hourlyIcon)

            TemperatureText(measurement: forecast.temperature, unit: unit, font: .caption)
                .frame(height: LayoutConstants.Size.hourlyTempHeight)

            Text(forecast.precipitationProbability > 0 ? "\(Int(forecast.precipitationProbability))%" : " ")
                .font(.caption2)
                .foregroundStyle(precipColor)
                .frame(height: LayoutConstants.Size.hourlyPrecipTextHeight)

            precipBar
                .frame(height: LayoutConstants.Size.hourlyPrecipBarHeight)
        }
        .frame(width: LayoutConstants.Size.hourlyColumnWidth)
        .padding(.vertical, LayoutConstants.Size.hourlyVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.hourlyRow)
                .fill(conditionTint)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hourlyAccessibilityLabel)
    }

    private var hourlyAccessibilityLabel: String {
        let time = isNow ? String(localized: "Now") : forecast.date.formatted(.dateTime.hour())
        let temp = forecast.temperature.formatted(as: unit)
        let condition = forecast.condition.displayName
        var label = "\(time), \(condition), \(temp)"
        if forecast.precipitationProbability > 0 {
            let precipType = isSnowy ? String(localized: "snow") : String(localized: "rain")
            label += ", \(Int(forecast.precipitationProbability))% \(precipType)"
        }
        return label
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
        isSnowy ? .white.opacity(LayoutConstants.Opacity.snowPrecip) : .cyan
    }

    private var precipBar: some View {
        let mm = forecast.precipitation.converted(to: .millimeters).value
        let fraction = min(mm / 2.0, 1.0)
        let barHeight = LayoutConstants.Size.hourlyPrecipBarHeight * fraction
        return VStack {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 1)
                .fill(mm > 0 ? precipColor : Color.clear)
                .frame(width: LayoutConstants.Size.precipBarWidth, height: barHeight)
        }
    }

    private var conditionTint: Color {
        switch forecast.condition {
            case .rain, .heavyRain, .showers, .heavyShowers, .drizzle, .freezingDrizzle, .freezingRain:
                return .cyan.opacity(LayoutConstants.Opacity.rainTint)
            case .snow, .heavySnow, .snowShowers, .sleet:
                return .white.opacity(LayoutConstants.Opacity.snowTint)
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
