import SwiftUI

struct WeatherAlertBanner: View {
    let alerts: [WeatherAlert]
    @State private var expandedAlertID: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            ForEach(alerts) { alert in
                VStack(alignment: .leading, spacing: 0) {
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
                                .lineLimit(expandedAlertID == alert.id ? nil : 2)
                        }

                        Spacer()

                        Image(systemName: expandedAlertID == alert.id ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(LayoutConstants.Padding.card)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            expandedAlertID = expandedAlertID == alert.id ? nil : alert.id
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(alert.severity.displayName): \(alert.event)")
                    .accessibilityValue(alert.headline)
                    .accessibilityHint(String(localized: "Double-tap to expand or collapse"))

                    if expandedAlertID == alert.id {
                        VStack(alignment: .leading, spacing: 4) {
                            if !alert.description.isEmpty {
                                Text(alert.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                if let endDate = alert.endDate {
                                    Label(
                                        String(localized: "Until \(endDate.formatted(date: .abbreviated, time: .shortened))"),
                                        systemImage: "clock"
                                    )
                                }
                                if let source = alert.source {
                                    Label(source, systemImage: "building.2")
                                }
                            }
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, LayoutConstants.Padding.card)
                        .padding(.bottom, LayoutConstants.Padding.card)
                        .transition(.opacity)
                    }
                }
                .background(
                    color(for: alert.severity).opacity(0.1),
                    in: RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                )
            }
        }
        .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
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
            description: "Winds up to 90 km/h expected along the coast from midnight.",
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
