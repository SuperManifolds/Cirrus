import Charts
import SwiftUI

struct PrecipitationChartView: View {
    let minutely: [MinuteForecast]
    let condition: WeatherCondition
    @State private var selectedEntry: MinuteForecast?

    private var isSnow: Bool {
        // Use precipitation type from data if any entry has it
        if minutely.contains(where: { $0.precipitationType != nil }) {
            return minutely.contains { $0.precipitationType == .snow || $0.precipitationType == .sleet }
        }
        // Fall back to current condition
        switch condition {
            case .snow, .heavySnow, .snowShowers, .sleet:
                return true
            default:
                return false
        }
    }

    private var precipLabel: String {
        isSnow ? String(localized: "Snow") : String(localized: "Rain")
    }

    private var barColor: Color { isSnow ? .white.opacity(0.7) : .cyan }
    private var barEmptyColor: Color {
        isSnow
            ? .white.opacity(LayoutConstants.Opacity.precipBarEmpty)
            : .cyan.opacity(LayoutConstants.Opacity.precipBarEmpty)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selectedEntry != nil ? tooltipText : summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart(minutely) { entry in
                BarMark(
                    x: .value("Time", entry.date),
                    y: .value("Intensity", entry.precipitationIntensity)
                )
                .foregroundStyle(
                    entry.id == selectedEntry?.id
                        ? barColor.opacity(0.9)
                        : (entry.precipitationIntensity > 0 ? barColor : barEmptyColor)
                )
                .cornerRadius(LayoutConstants.Size.precipBarCornerRadius)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0 ... max(
                minutely.map(\.precipitationIntensity).max() ?? 0.5,
                LayoutConstants.Size.precipMinIntensity
            ))
            .chartOverlay { proxy in
                GeometryReader { _ in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onContinuousHover { phase in
                            switch phase {
                                case .active(let location):
                                    if let date: Date = proxy.value(atX: location.x) {
                                        selectedEntry = minutely.min(by: {
                                            abs($0.date.timeIntervalSince(date))
                                                < abs($1.date.timeIntervalSince(date))
                                        })
                                    }
                                case .ended:
                                    selectedEntry = nil
                            }
                        }
                }
            }
            .frame(height: LayoutConstants.Size.precipBarHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(summaryText)

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

    private var tooltipText: String {
        guard let entry = selectedEntry else { return summaryText }
        let time = entry.date.formatted(date: .omitted, time: .shortened)
        let measurement = Measurement(value: entry.precipitationIntensity, unit: UnitLength.millimeters)
        let formatted = measurement.formatted(
            .measurement(width: .abbreviated, usage: .rainfall,
                         numberFormatStyle: .number.precision(.fractionLength(1)))
        )
        return "\(time) — \(formatted)/h"
    }

    private var summaryText: String {
        guard let firstRainIndex = minutely.firstIndex(where: { $0.precipitationIntensity > 0 }) else {
            return String(localized: "No precipitation expected")
        }

        let isRainingNow = firstRainIndex == minutely.startIndex
        if isRainingNow {
            if let stopIndex = minutely[firstRainIndex...].firstIndex(where: { $0.precipitationIntensity == 0 }) {
                let stopTime = minutely[stopIndex].date.formatted(date: .omitted, time: .shortened)
                return String(localized: "\(precipLabel) until around \(stopTime)")
            }
            let lastTime = minutely.last?.date.formatted(date: .omitted, time: .shortened) ?? ""
            return String(localized: "\(precipLabel) continuing past \(lastTime)")
        } else {
            let startTime = minutely[firstRainIndex].date.formatted(date: .omitted, time: .shortened)
            return String(localized: "\(precipLabel) expected around \(startTime)")
        }
    }
}

#if DEBUG
#Preview("With rain") {
    PrecipitationChartView(
        minutely: MockWeatherProvider.mockMinutely(),
        condition: .rain
    )
    .frame(width: 320)
}

#Preview("No rain") {
    let now = Date()
    let empty = (0..<4).map { idx in
        MinuteForecast(
            date: Calendar.current.date(byAdding: .minute, value: idx * 15, to: now) ?? now,
            precipitationIntensity: 0,
            precipitationChance: 0,
            precipitationType: nil
        )
    }
    PrecipitationChartView(minutely: empty, condition: .clear)
        .frame(width: 320)
}

#Preview("Steady snow") {
    let now = Date()
    let snow = (0..<24).map { idx in
        MinuteForecast(
            date: Calendar.current.date(byAdding: .minute, value: idx * 5, to: now) ?? now,
            precipitationIntensity: 0.3 + Double.random(in: 0...0.4),
            precipitationChance: 90,
            precipitationType: .snow
        )
    }
    PrecipitationChartView(minutely: snow, condition: .snow)
        .frame(width: 320)
}
#endif
