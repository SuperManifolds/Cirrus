import SwiftUI

struct CurrentConditionsView: View {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    let today: DailyForecast?
    let locationName: String
    let isPinnedLocation: Bool
    let airQuality: AirQuality?
    let pollen: Pollen?
    let summary: String?
    let unit: TemperatureUnit
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    var onLocationSelected: (Location) -> Void
    var onUseCurrentLocation: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            LocationSearchHeader(
                locationName: locationName,
                isPinnedLocation: isPinnedLocation,
                searchViewModel: locationSearchViewModel,
                settingsViewModel: settingsViewModel,
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(localized: "\(current.condition.displayName), \(current.temperature.formatted(as: unit)), feels like \(current.apparentTemperature.formatted(as: unit))"))

            if let summary {
                Text(summary)
                    .font(.callout)
                    .italic()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            DetailCardsGrid(cards: [
                WindCard(current: current, hourly: hourly),
                HumidityCard(current: current, hourly: hourly),
                UVIndexCard(current: current, hourly: hourly),
                PressureCard(current: current, hourly: hourly),
                CloudCoverCard(current: current, hourly: hourly),
                VisibilityCard(current: current, hourly: hourly),
                DewPointCard(current: current, hourly: hourly, unit: unit),
                SnowDepthCard(current: current),
                AQICard(airQuality: airQuality),
                PM25Card(airQuality: airQuality),
                PM10Card(airQuality: airQuality),
                PollenCard(name: String(localized: "Birch Pollen"), grains: pollen?.birch),
                PollenCard(name: String(localized: "Grass Pollen"), grains: pollen?.grass),
                PollenCard(name: String(localized: "Alder Pollen"), grains: pollen?.alder),
                PollenCard(name: String(localized: "Mugwort Pollen"), grains: pollen?.mugwort),
                PollenCard(name: String(localized: "Olive Pollen"), grains: pollen?.olive),
                PollenCard(name: String(localized: "Ragweed Pollen"), grains: pollen?.ragweed),
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
        hourly: MockWeatherProvider.mockHourly(),
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
        airQuality: AirQuality(
            aqi: 35, aqiCategory: .fair, pm25: 8.5, pm10: 15.2,
            ozone: 62, nitrogenDioxide: 12, sulphurDioxide: 3,
            carbonMonoxide: 210, timestamp: Date()
        ),
        pollen: Pollen(
            alder: 5, birch: 45, grass: 80,
            mugwort: 0, olive: 0, ragweed: 0, timestamp: Date()
        ),
        summary: "Partly cloudy this morning, clearing by afternoon with highs around 24°C.",
        unit: .celsius,
        locationSearchViewModel: LocationSearchViewModel.preview(),
        settingsViewModel: SettingsViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {}
    )
    .frame(width: 320)
}
#endif
