import SwiftUI

@main
struct CirrusApp: App {
    private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var locationService = LocationService()
    @State private var weatherViewModel: WeatherViewModel?
    @State private var locationSearchViewModel: LocationSearchViewModel?

    var body: some Scene {
        MenuBarExtra {
            if !isPreview, let weatherVM = weatherViewModel,
               let searchVM = locationSearchViewModel {
                MenuBarView(
                    weatherViewModel: weatherVM,
                    settingsViewModel: settingsViewModel,
                    locationSearchViewModel: searchVM,
                    locationService: locationService
                )
            }
        } label: {
            if !isPreview, let weatherVM = weatherViewModel {
                MenuBarLabel(
                    weatherViewModel: weatherVM,
                    settingsViewModel: settingsViewModel
                )
            } else {
                Label(String(localized: "Cirrus"), systemImage: "cloud.sun.fill")
                    .symbolRenderingMode(.multicolor)
            }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: settingsViewModel.weatherProvider) { _, newProvider in
            weatherViewModel?.switchProvider(to: newProvider)
        }
        .onChange(of: settingsViewModel.refreshInterval) { _, newInterval in
            weatherViewModel?.startAutoRefresh(interval: newInterval.duration)
        }
        .onChange(of: settingsViewModel.useCurrentLocation) { _, useCurrentLocation in
            handleLocationChange(useCurrentLocation: useCurrentLocation)
        }
        .onChange(of: settingsViewModel.pinnedLocation) { _, _ in
            handleLocationChange(useCurrentLocation: settingsViewModel.useCurrentLocation)
        }
        .onChange(of: settingsViewModel.showAISummary) { _, enabled in
            weatherViewModel?.enableAISummary = enabled
        }
        .onChange(of: settingsViewModel.temperatureUnit) { _, unit in
            weatherViewModel?.temperatureUnit = unit
        }

        Settings {
            if let searchVM = locationSearchViewModel {
                SettingsView(
                    settingsViewModel: settingsViewModel,
                    locationSearchViewModel: searchVM,
                    locationProvider: locationService
                )
            }
        }
    }

    init() {
        let settings = SettingsViewModel()
        let locService = LocationService()
        let provider: any WeatherProviding = Self.makeProvider(for: settings.weatherProvider)

        _settingsViewModel = StateObject(wrappedValue: settings)
        _locationService = State(wrappedValue: locService)

        let weatherVM = WeatherViewModel(
            weatherProvider: provider,
            locationProvider: locService
        )
        weatherVM.enableAISummary = settings.showAISummary
        weatherVM.temperatureUnit = settings.temperatureUnit
        _weatherViewModel = State(wrappedValue: weatherVM)
        _locationSearchViewModel = State(wrappedValue: LocationSearchViewModel(locationProvider: locService))

        if settings.useCurrentLocation {
            locService.requestAuthorization()
        } else if let pinned = settings.pinnedLocation {
            locService.currentLocation = pinned
        }

        weatherVM.startAutoRefresh(interval: settings.refreshInterval.duration)

        Task { await weatherVM.refresh() }
    }

    private func handleLocationChange(useCurrentLocation: Bool) {
        if useCurrentLocation {
            locationService.requestAuthorization()
            locationService.requestLocation()
        } else if let pinned = settingsViewModel.pinnedLocation {
            locationService.currentLocation = pinned
        }
    }

    private static func makeProvider(for kind: WeatherProviderKind) -> any WeatherProviding {
        switch kind {
            case .openMeteo: OpenMeteoService()
            case .weatherKit: WeatherKitService()
        }
    }
}
