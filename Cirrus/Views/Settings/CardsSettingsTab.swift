import SwiftUI

struct CardsSettingsTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    private struct CardInfo: Identifiable {
        let id: String
        let title: String
        let icon: String
        let iconColor: Color
    }

    private let weatherCards: [CardInfo] = [
        CardInfo(id: "wind", title: String(localized: "Wind"), icon: "wind", iconColor: .teal),
        CardInfo(id: "humidity", title: String(localized: "Humidity"), icon: "humidity.fill", iconColor: .cyan),
        CardInfo(id: "uvIndex", title: String(localized: "UV Index"), icon: "sun.max.fill", iconColor: .orange),
        CardInfo(id: "pressure", title: String(localized: "Pressure"), icon: "gauge.medium", iconColor: .purple),
        CardInfo(id: "cloudCover", title: String(localized: "Cloud Cover"), icon: "cloud.fill", iconColor: .gray),
        CardInfo(id: "visibility", title: String(localized: "Visibility"), icon: "eye.fill", iconColor: .mint),
        CardInfo(id: "dewPoint", title: String(localized: "Dew Point"), icon: "drop.degreesign.fill", iconColor: .teal),
        CardInfo(id: "snowDepth", title: String(localized: "Snow Depth"), icon: "snowflake", iconColor: .blue),
        CardInfo(id: "sunrise", title: String(localized: "Sunrise"), icon: "sunrise.fill", iconColor: .yellow),
        CardInfo(id: "sunset", title: String(localized: "Sunset"), icon: "sunset.fill", iconColor: .orange)
    ]

    private let airQualityCards: [CardInfo] = [
        CardInfo(id: "aqi", title: String(localized: "Air Quality"), icon: "aqi.medium", iconColor: .green),
        CardInfo(id: "pm25", title: String(localized: "PM2.5"), icon: "circle.dotted.circle", iconColor: .indigo),
        CardInfo(id: "pm10", title: String(localized: "PM10"), icon: "circle.dotted.circle", iconColor: .brown),
        CardInfo(id: "ozone", title: String(localized: "Ozone"), icon: "aqi.low", iconColor: .blue),
        CardInfo(id: "no2", title: "NO₂", icon: "aqi.low", iconColor: .orange),
        CardInfo(id: "so2", title: "SO₂", icon: "aqi.low", iconColor: .yellow),
        CardInfo(id: "co", title: "CO", icon: "aqi.low", iconColor: .red)
    ]

    var body: some View {
        Form {
            Section(String(localized: "Weather")) {
                ForEach(weatherCards) { card in
                    cardToggle(card)
                }
            }

            Section(String(localized: "Air Quality")) {
                ForEach(airQualityCards) { card in
                    cardToggle(card)
                }
            }

            Text(cardVisibilityHint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var cardVisibilityHint: String {
        String(
            localized: "Hidden cards won't show even when data is available. Cards still auto-hide when not relevant."
        )
    }

    private func cardToggle(_ card: CardInfo) -> some View {
        Toggle(isOn: Binding(
            get: { !settingsViewModel.hiddenCardIDs.contains(card.id) },
            set: { enabled in
                if enabled {
                    settingsViewModel.hiddenCardIDs.remove(card.id)
                } else {
                    settingsViewModel.hiddenCardIDs.insert(card.id)
                }
            }
        )) {
            Label(card.title, systemImage: card.icon)
                .foregroundStyle(card.iconColor)
        }
    }
}

#if DEBUG
#Preview {
    CardsSettingsTab(settingsViewModel: SettingsViewModel())
        .frame(width: 420, height: 500)
}
#endif
