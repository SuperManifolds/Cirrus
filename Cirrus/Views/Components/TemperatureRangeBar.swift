import Charts
import SwiftUI

struct TemperatureRangeBar: View {
    let dayLow: Double
    let dayHigh: Double
    let weekMin: Double
    let weekMax: Double

    var body: some View {
        Chart {
            BarMark(
                xStart: .value("Low", dayLow),
                xEnd: .value("High", dayHigh),
                y: .value("Day", 0)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.blue, .yellow, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(2)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartXScale(domain: weekMin ... weekMax)
        .chartPlotStyle { plot in
            plot.background(.quaternary.opacity(0.5))
                .cornerRadius(2)
        }
        .frame(height: 4)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 8) {
        TemperatureRangeBar(dayLow: 14, dayHigh: 24, weekMin: 10, weekMax: 28)
            .frame(width: 100)
        TemperatureRangeBar(dayLow: 10, dayHigh: 18, weekMin: 10, weekMax: 28)
            .frame(width: 100)
        TemperatureRangeBar(dayLow: 20, dayHigh: 28, weekMin: 10, weekMax: 28)
            .frame(width: 100)
    }
    .padding()
}
#endif
