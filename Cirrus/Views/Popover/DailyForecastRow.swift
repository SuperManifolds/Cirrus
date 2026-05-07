import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast
    let unit: TemperatureUnit
    let weekMin: Double
    let weekMax: Double

    private var isToday: Bool {
        Calendar.current.isDateInToday(forecast.date)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(isToday ? String(localized: "Today") : forecast.date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.callout)
                .frame(width: LayoutConstants.Size.dailyDayWidth, alignment: .leading)

            WeatherIcon(condition: forecast.condition, isDaytime: true, size: 16)

            if forecast.precipitationProbability > 0 {
                Text("\(Int(forecast.precipitationProbability))%")
                    .font(.caption2)
                    .foregroundStyle(.cyan)
                    .frame(width: LayoutConstants.Size.dailyPrecipWidth, alignment: .trailing)
            } else {
                Spacer()
                    .frame(width: LayoutConstants.Size.dailyPrecipWidth)
            }

            TemperatureText(measurement: forecast.lowTemperature, unit: unit, font: .caption)
                .foregroundStyle(.secondary)
                .frame(width: LayoutConstants.Size.dailyTempWidth, alignment: .trailing)

            TemperatureRangeBar(
                dayLow: forecast.lowTemperature.converted(to: .celsius).value,
                dayHigh: forecast.highTemperature.converted(to: .celsius).value,
                weekMin: weekMin,
                weekMax: weekMax
            )

            TemperatureText(measurement: forecast.highTemperature, unit: unit, font: .caption)
                .frame(width: LayoutConstants.Size.dailyTempWidth, alignment: .trailing)
        }
        .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
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
