import SwiftUI

struct CurrentConditionsView: View {
    let current: CurrentWeather
    let today: DailyForecast?
    let locationName: String
    let isPinnedLocation: Bool
    let unit: TemperatureUnit
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    var onLocationSelected: (Location) -> Void
    var onUseCurrentLocation: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            LocationSearchHeader(
                locationName: locationName,
                isPinnedLocation: isPinnedLocation,
                searchViewModel: locationSearchViewModel,
                onLocationSelected: onLocationSelected,
                onUseCurrentLocation: onUseCurrentLocation
            )
            .padding(.bottom, 2)

            HStack(spacing: 8) {
                WeatherIcon(
                    condition: current.condition,
                    isDaytime: current.isDaytime,
                    size: LayoutConstants.Size.conditionIcon
                )

                TemperatureText(
                    measurement: current.temperature,
                    unit: unit,
                    font: .system(size: LayoutConstants.Size.conditionTemperature, weight: .light)
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

            DetailCardsGrid(cards: [
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
            ])
        }
        .padding(.vertical, LayoutConstants.Padding.sectionVertical)
        .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
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
        isPinnedLocation: false,
        unit: .celsius,
        locationSearchViewModel: LocationSearchViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {}
    )
    .frame(width: 320)
}
#endif
