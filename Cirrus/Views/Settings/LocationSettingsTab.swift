import CoreLocation
import SwiftUI

struct LocationSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var locationSearchViewModel: LocationSearchViewModel
    let locationProvider: LocationService

    var body: some View {
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
}

#if DEBUG
#Preview {
    LocationSettingsTab(
        settingsViewModel: SettingsViewModel(),
        locationSearchViewModel: LocationSearchViewModel(locationProvider: MockLocationProvider()),
        locationProvider: LocationService()
    )
    .frame(width: 420, height: 320)
}
#endif
