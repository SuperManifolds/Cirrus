import SwiftUI

struct ProviderSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
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
    ProviderSettingsTab(settingsViewModel: SettingsViewModel())
        .frame(width: 420, height: 320)
}
#endif
