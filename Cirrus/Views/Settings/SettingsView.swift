import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    @ObservedObject var updaterViewModel: UpdaterViewModel
    let locationProvider: LocationService

    var body: some View {
        TabView {
            GeneralSettingsTab(settingsViewModel: settingsViewModel, updaterViewModel: updaterViewModel)
                .tabItem { Label(String(localized: "General"), systemImage: "gear") }
            LocationSettingsTab(
                settingsViewModel: settingsViewModel,
                locationSearchViewModel: locationSearchViewModel,
                locationProvider: locationProvider
            )
            .tabItem { Label(String(localized: "Location"), systemImage: "location") }
            ProviderSettingsTab(settingsViewModel: settingsViewModel)
                .tabItem { Label(String(localized: "Provider"), systemImage: "cloud") }
        }
        .frame(width: LayoutConstants.Size.settingsWidth, height: LayoutConstants.Size.settingsHeight)
    }
}

#if DEBUG
#Preview {
    SettingsView(
        settingsViewModel: SettingsViewModel(),
        locationSearchViewModel: LocationSearchViewModel(locationProvider: MockLocationProvider()),
        updaterViewModel: UpdaterViewModel(),
        locationProvider: LocationService()
    )
}
#endif
