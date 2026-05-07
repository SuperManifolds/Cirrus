import SwiftUI

struct GeneralSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
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

            Toggle(String(localized: "Show Air Quality"), isOn: $settingsViewModel.showAirQuality)

            Toggle(String(localized: "Launch at Login"), isOn: $settingsViewModel.launchAtLogin)
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    GeneralSettingsTab(settingsViewModel: SettingsViewModel())
        .frame(width: 420, height: 320)
}
#endif
