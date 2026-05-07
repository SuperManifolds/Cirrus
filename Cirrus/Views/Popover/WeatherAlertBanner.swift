import SwiftUI

struct WeatherAlertBanner: View {
    let alerts: [WeatherAlert]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(alerts) { alert in
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(color(for: alert.severity))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(alert.event)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(alert.headline)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(LayoutConstants.Padding.card)
                .background(
                    color(for: alert.severity).opacity(0.1),
                    in: RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func color(for severity: AlertSeverity) -> Color {
        switch severity {
            case .extreme: .red
            case .severe: .orange
            case .moderate: .yellow
            case .minor: .blue
            case .unknown: .gray
        }
    }
}

#if DEBUG
#Preview {
    WeatherAlertBanner(alerts: [
        WeatherAlert(
            id: "1",
            event: "Storm Warning",
            severity: .severe,
            headline: "Strong winds expected in coastal areas",
            description: "",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 6),
            source: "MET Norway"
        ),
        WeatherAlert(
            id: "2",
            event: "Flood Advisory",
            severity: .moderate,
            headline: "Minor flooding possible in low-lying areas",
            description: "",
            startDate: Date(),
            endDate: nil,
            source: "MET Norway"
        )
    ])
    .frame(width: 320)
}
#endif
