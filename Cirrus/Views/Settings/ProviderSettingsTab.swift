import SwiftUI

struct ProviderSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Picker(String(localized: "Weather Provider"), selection: $settingsViewModel.weatherProvider) {
                ForEach(WeatherProviderRegistry.providers, id: \.kind) { provider in
                    Text(provider.displayName).tag(provider.kind)
                }
            }

            Section {
                let provider = WeatherProviderRegistry.provider(for: settingsViewModel.weatherProvider)
                Text(provider.providerDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    ProviderSettingsTab(settingsViewModel: SettingsViewModel())
        .frame(width: 420, height: 320)
}
#endif
