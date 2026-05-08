import Charts
import SwiftUI

struct PrecipitationChartView: View {
    let minutely: [MinuteForecast]
    @State private var selectedEntry: MinuteForecast?

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
                        ? .cyan.opacity(0.9)
                        : (entry.precipitationIntensity > 0
                            ? .cyan
                            : .cyan.opacity(LayoutConstants.Opacity.precipBarEmpty))
                )
                .cornerRadius(LayoutConstants.Size.precipBarCornerRadius)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: stride)) {
                    AxisValueLabel(format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var stride: Int {
        let count = minutely.count
        if count <= 4 { return 15 }
        if count <= 12 { return 5 }
        return 10
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
                return String(localized: "Rain until around \(stopTime)")
            }
            let lastTime = minutely.last?.date.formatted(date: .omitted, time: .shortened) ?? ""
            return String(localized: "Rain continuing past \(lastTime)")
        } else {
            let startTime = minutely[firstRainIndex].date.formatted(date: .omitted, time: .shortened)
            return String(localized: "Rain expected around \(startTime)")
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
