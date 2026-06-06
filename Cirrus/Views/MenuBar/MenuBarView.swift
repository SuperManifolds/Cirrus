import CoreLocation
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    let locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            if let snapshot = weatherViewModel.snapshot {
                if !snapshot.alerts.isEmpty {
                    WeatherAlertBanner(alerts: snapshot.alerts)
                    Divider()
                }

                CurrentConditionsView(
                    current: snapshot.current,
                    hourly: snapshot.hourly,
                    today: snapshot.daily.first,
                    locationName: snapshot.location.name,
                    isPinnedLocation: !settingsViewModel.useCurrentLocation,
                    airQuality: settingsViewModel.showAirQuality ? weatherViewModel.airQuality : nil,
                    pollen: settingsViewModel.showAirQuality ? weatherViewModel.pollen : nil,
                    summary: settingsViewModel.showAISummary ? weatherViewModel.summary : nil,
                    unit: settingsViewModel.temperatureUnit,
                    locationSearchViewModel: locationSearchViewModel,
                    settingsViewModel: settingsViewModel,
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

                if let minutely = snapshot.minutely,
                   minutely.contains(where: { $0.precipitationIntensity > 0 }) {
                    Divider()
                    PrecipitationChartView(minutely: minutely, condition: snapshot.current.condition)
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
                VStack(spacing: LayoutConstants.Spacing.sectionGap) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 80, height: 16)
                    HStack(spacing: 8) {
                        Circle()
                            .frame(width: LayoutConstants.Size.conditionIcon,
                                   height: LayoutConstants.Size.conditionIcon)
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 50, height: LayoutConstants.Size.conditionTemperature)
                    }
                    Grid(horizontalSpacing: LayoutConstants.Spacing.cardGrid,
                         verticalSpacing: LayoutConstants.Spacing.cardGrid) {
                        GridRow {
                            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                                .frame(height: 44)
                            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                                .frame(height: 44)
                        }
                    }
                    .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
                }
                .redacted(reason: .placeholder)
                .padding(.vertical, LayoutConstants.Padding.sectionVertical)
            } else if let error = weatherViewModel.error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
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
                .padding(LayoutConstants.Padding.errorState)
                Divider()
            } else {
                VStack(spacing: 8) {
                    if locationService.authorizationStatus == .denied
                        || locationService.authorizationStatus == .restricted {
                        Image(systemName: "location.slash.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                            .accessibilityHidden(true)
                        Text(String(localized: "Location access denied"))
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(String(localized: "Enable in System Settings or search for a city above."))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        ProgressView()
                            .controlSize(.small)
                        Text(String(localized: "Getting your location..."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(LayoutConstants.Padding.errorState)
                Divider()
            }

            MenuBarFooter(
                lastUpdated: weatherViewModel.snapshot?.fetchedAt,
                attributionName: weatherViewModel.snapshot?.attributionName,
                attributionURL: weatherViewModel.snapshot?.attributionURL
            )
        }
        .frame(width: WeatherDefaults.popoverWidth)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: weatherViewModel.snapshot != nil)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: weatherViewModel.isLoading)
    }
}

struct MenuBarButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.button)
                    .fill(.primary.opacity(backgroundOpacity(isPressed: configuration.isPressed)))
            )
            .contentShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.button))
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private func backgroundOpacity(isPressed: Bool) -> Double {
        if isPressed { return LayoutConstants.Opacity.buttonPressed }
        if isHovered { return LayoutConstants.Opacity.buttonPressed * 0.7 }
        return LayoutConstants.Opacity.buttonResting
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
