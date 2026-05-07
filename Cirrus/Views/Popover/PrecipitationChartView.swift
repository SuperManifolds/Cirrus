import SwiftUI

struct PrecipitationChartView: View {
    let minutely: [MinuteForecast]

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var maxIntensity: Double {
        max(minutely.map(\.precipitationIntensity).max() ?? 0, 0.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(minutely) { entry in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(entry.precipitationIntensity > 0 ? Color.cyan : Color.cyan.opacity(0.15))
                        .frame(height: barHeight(for: entry.precipitationIntensity))
                }
            }
            .frame(height: 30)

            HStack {
                if let first = minutely.first {
                    Text(Self.timeFormatter.string(from: first.date))
                }
                Spacer()
                if let last = minutely.last {
                    Text(Self.timeFormatter.string(from: last.date))
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func barHeight(for intensity: Double) -> CGFloat {
        let minHeight: CGFloat = 2
        let maxHeight: CGFloat = 30
        guard intensity > 0 else { return minHeight }
        let fraction = min(intensity / maxIntensity, 1.0)
        return minHeight + (maxHeight - minHeight) * fraction
    }

    private var summaryText: String {
        guard minutely.contains(where: { $0.precipitationIntensity > 0 }) else {
            return String(localized: "No precipitation expected")
        }

        let isRainingNow = minutely.first?.precipitationIntensity ?? 0 > 0
        if isRainingNow {
            if minutely.contains(where: { $0.precipitationIntensity == 0 }) {
                return String(localized: "Precipitation expected to ease")
            }
            return String(localized: "Precipitation continuing")
        } else {
            return String(localized: "Precipitation expected soon")
        }
    }
}

#if DEBUG
#Preview("With rain") {
    PrecipitationChartView(minutely: MockWeatherProvider.mockMinutely())
        .frame(width: 320)
}

#Preview("No rain") {
    let now = Date()
    let empty = (0..<4).map { idx in
        MinuteForecast(
            date: Calendar.current.date(byAdding: .minute, value: idx * 15, to: now) ?? now,
            precipitationIntensity: 0,
            precipitationChance: 0
        )
    }
    PrecipitationChartView(minutely: empty)
        .frame(width: 320)
}
#endif
