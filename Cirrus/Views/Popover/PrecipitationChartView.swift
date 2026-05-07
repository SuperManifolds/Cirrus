import SwiftUI

struct PrecipitationChartView: View {
    let minutely: [MinuteForecast]
    @State private var hoveredIndex: Int?

    private var maxIntensity: Double {
        max(minutely.map(\.precipitationIntensity).max() ?? 0, 0.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hoveredIndex != nil ? tooltipText : summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .animation(.none, value: hoveredIndex)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(minutely.enumerated()), id: \.element.id) { index, entry in
                    RoundedRectangle(cornerRadius: LayoutConstants.Size.precipBarCornerRadius)
                        .fill(barColor(index: index, intensity: entry.precipitationIntensity))
                        .frame(height: barHeight(for: entry.precipitationIntensity))
                        .onHover { hovering in
                            hoveredIndex = hovering ? index : nil
                        }
                }
            }
            .frame(height: LayoutConstants.Size.precipBarHeight)

            HStack {
                if let first = minutely.first {
                    Text(first.date.formatted(date: .omitted, time: .shortened))
                }
                Spacer()
                if let last = minutely.last {
                    Text(last.date.formatted(date: .omitted, time: .shortened))
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func barColor(index: Int, intensity: Double) -> Color {
        if index == hoveredIndex {
            return .cyan.opacity(0.9)
        }
        return intensity > 0 ? .cyan : .cyan.opacity(LayoutConstants.Opacity.precipBarEmpty)
    }

    private func barHeight(for intensity: Double) -> CGFloat {
        let minHeight = LayoutConstants.Size.precipBarMinHeight
        let maxHeight = LayoutConstants.Size.precipBarHeight
        guard intensity > 0 else { return minHeight }
        let fraction = min(intensity / maxIntensity, 1.0)
        return minHeight + (maxHeight - minHeight) * fraction
    }

    private var tooltipText: String {
        guard let index = hoveredIndex, minutely.indices.contains(index) else {
            return summaryText
        }
        let entry = minutely[index]
        let time = entry.date.formatted(date: .omitted, time: .shortened)
        let measurement = Measurement(value: entry.precipitationIntensity, unit: UnitLength.millimeters)
        let formatted = measurement.formatted(
            .measurement(width: .abbreviated, usage: .rainfall,
                         numberFormatStyle: .number.precision(.fractionLength(1)))
        )
        return "\(time) — \(formatted)/h"
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
