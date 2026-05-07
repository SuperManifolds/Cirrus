import CoreLocation
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    let locationProvider: LocationService

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label(String(localized: "General"), systemImage: "gear") }
            locationTab
                .tabItem { Label(String(localized: "Location"), systemImage: "location") }
            providerTab
                .tabItem { Label(String(localized: "Provider"), systemImage: "cloud") }
        }
        .frame(width: 420, height: 320)
    }

    private var generalTab: some View {
        Form {
            Picker(String(localized: "Temperature"), selection: $settingsViewModel.temperatureUnit) {
                ForEach(TemperatureUnit.allCases) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }

            Picker(String(localized: "Menu Bar Display"), selection: $settingsViewModel.menuBarDisplayMode) {
                ForEach(MenuBarDisplayMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }

            Picker(String(localized: "Refresh Interval"), selection: $settingsViewModel.refreshInterval) {
                ForEach(RefreshInterval.allCases) { interval in
                    Text(interval.displayName).tag(interval)
                }
            }

            Toggle(String(localized: "Colored Menu Bar Icon"), isOn: $settingsViewModel.coloredMenuBarIcon)

            Toggle(String(localized: "Launch at Login"), isOn: $settingsViewModel.launchAtLogin)
        }
        .formStyle(.grouped)
    }

    private var locationTab: some View {
        Form {
            Toggle(String(localized: "Use Current Location"), isOn: $settingsViewModel.useCurrentLocation)

            if !settingsViewModel.useCurrentLocation {
                Section(String(localized: "Search Location")) {
                    TextField(String(localized: "City name..."), text: $locationSearchViewModel.searchText)
                        .textFieldStyle(.roundedBorder)

                    if locationSearchViewModel.isSearching {
                        ProgressView()
                            .controlSize(.small)
                    }

                    ForEach(locationSearchViewModel.results) { location in
                        Button {
                            settingsViewModel.pinnedLocation = location
                            locationSearchViewModel.clearResults()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .font(.body)
                                if let area = location.administrativeArea {
                                    Text(area)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let pinned = settingsViewModel.pinnedLocation {
                    Section(String(localized: "Pinned Location")) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(pinned.name)
                                    .font(.body)
                                if let area = pinned.administrativeArea {
                                    Text(area)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button(String(localized: "Remove")) {
                                settingsViewModel.pinnedLocation = nil
                            }
                            .controlSize(.small)
                        }
                    }
                }
            } else {
                Section {
                    switch locationProvider.authorizationStatus {
                        case .notDetermined:
                            Button(String(localized: "Grant Location Access")) {
                                locationProvider.requestAuthorization()
                            }
                        case .denied, .restricted:
                            Text(String(localized: """
                                Location access denied. Enable in \
                                System Settings > Privacy & Security > Location Services.
                                """))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        default:
                            if let location = locationProvider.currentLocation {
                                Label(location.name, systemImage: "location.fill")
                            } else {
                                Label(String(localized: "Locating..."), systemImage: "location.fill")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var providerTab: some View {
        Form {
            Picker(String(localized: "Weather Provider"), selection: $settingsViewModel.weatherProvider) {
                ForEach(WeatherProviderKind.allCases) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }

            Section {
                switch settingsViewModel.weatherProvider {
                    case .openMeteo:
                        Text(String(localized: """
                            Open-Meteo provides free weather data with no API key required. \
                            Data is sourced from national weather services.
                            """))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    case .weatherKit:
                        Text(String(localized: """
                            Apple WeatherKit requires an Apple Developer membership. \
                            Provides up to 500,000 API calls per month.
                            """))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    SettingsView(
        settingsViewModel: SettingsViewModel(),
        locationSearchViewModel: LocationSearchViewModel(locationProvider: MockLocationProvider()),
        locationProvider: LocationService()
    )
}
#endif
