import FoundationModels
import SwiftUI

struct GeneralSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var updaterViewModel: UpdaterViewModel

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

            if SystemLanguageModel.default.availability == .available {
                Toggle(String(localized: "AI Weather Summary"), isOn: $settingsViewModel.showAISummary)
            }

            Toggle(String(localized: "Notifications"), isOn: $settingsViewModel.showNotifications)

            Toggle(String(localized: "Launch at Login"), isOn: $settingsViewModel.launchAtLogin)

            Button(String(localized: "Check for Updates...")) {
                updaterViewModel.checkForUpdates()
            }
            .disabled(!updaterViewModel.canCheckForUpdates)
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    GeneralSettingsTab(settingsViewModel: SettingsViewModel(), updaterViewModel: UpdaterViewModel())
        .frame(width: 420, height: 320)
}
#endif
