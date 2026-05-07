import SwiftUI

struct MenuBarView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

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
                    unit: settingsViewModel.temperatureUnit
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

            footer
        }
        .frame(width: WeatherDefaults.popoverWidth)
    }

    private var footer: some View {
        VStack(spacing: 4) {
            SettingsLink {
                Label(String(localized: "Settings..."), systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MenuBarButtonStyle())

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label(String(localized: "Quit Cirrus"), systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MenuBarButtonStyle())
        }
        .padding(8)
    }
}

struct MenuBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.primary.opacity(configuration.isPressed ? 0.1 : 0.04))
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
    }
}

#if DEBUG
#Preview {
    MenuBarView(
        weatherViewModel: WeatherViewModel.preview(),
        settingsViewModel: SettingsViewModel()
    )
}
#endif
