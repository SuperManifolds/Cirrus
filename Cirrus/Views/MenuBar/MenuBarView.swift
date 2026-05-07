import SwiftUI

struct MenuBarView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    let locationService: LocationService

    var body: some View {
        VStack(spacing: 0) {
            if let snapshot = weatherViewModel.snapshot {
                if !snapshot.alerts.isEmpty {
                    WeatherAlertBanner(alerts: snapshot.alerts)
                    Divider()
                }

                CurrentConditionsView(
                    current: snapshot.current,
                    today: snapshot.daily.first,
                    locationName: snapshot.location.name,
                    isPinnedLocation: !settingsViewModel.useCurrentLocation,
                    airQuality: settingsViewModel.showAirQuality ? weatherViewModel.airQuality : nil,
                    unit: settingsViewModel.temperatureUnit,
                    locationSearchViewModel: locationSearchViewModel,
                    onLocationSelected: { location in
                        settingsViewModel.pinnedLocation = location
                        settingsViewModel.useCurrentLocation = false
                        locationService.currentLocation = location
                    },
                    onUseCurrentLocation: {
                        settingsViewModel.useCurrentLocation = true
                        settingsViewModel.pinnedLocation = nil
                        locationService.requestAuthorization()
                        locationService.requestLocation()
                    }
                )

                if let minutely = snapshot.minutely, !minutely.isEmpty {
                    Divider()
                    PrecipitationChartView(minutely: minutely)
                }

                Divider()

                HourlyScrollView(
                    forecasts: snapshot.hourly,
                    unit: settingsViewModel.temperatureUnit
                )

                Divider()

                DailyForecastList(
                    forecasts: snapshot.daily,
                    unit: settingsViewModel.temperatureUnit
                )

                Divider()
            } else if weatherViewModel.isLoading {
                ProgressView()
                    .padding(40)
            } else if let error = weatherViewModel.error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(String(localized: "Retry")) {
                        Task { await weatherViewModel.refresh() }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(20)
                Divider()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "location.slash.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "Waiting for location..."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                Divider()
            }

            MenuBarFooter()
        }
        .frame(width: WeatherDefaults.popoverWidth)
    }
}

struct MenuBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.button)
                    .fill(.primary.opacity(
                        configuration.isPressed
                            ? LayoutConstants.Opacity.buttonPressed
                            : LayoutConstants.Opacity.buttonResting
                    ))
            )
            .contentShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.button))
    }
}

#if DEBUG
#Preview {
    MenuBarView(
        weatherViewModel: WeatherViewModel.preview(),
        settingsViewModel: SettingsViewModel(),
        locationSearchViewModel: LocationSearchViewModel(locationProvider: MockLocationProvider()),
        locationService: LocationService()
    )
}
#endif
