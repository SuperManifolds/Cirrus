import Charts
import SwiftUI

struct SparklineView: View {
    let values: [Double]
    var color: Color = .secondary

    var body: some View {
        Chart(Array(values.enumerated()), id: \.offset) { index, value in
            LineMark(
                x: .value("Index", index),
                y: .value("Value", value)
            )
            .foregroundStyle(color)
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 20) {
        SparklineView(values: [3, 5, 4, 7, 6, 8, 10, 9], color: .teal)
            .frame(width: 40, height: 16)
        SparklineView(values: [60, 55, 50, 45, 42, 40, 38, 35], color: .cyan)
            .frame(width: 40, height: 16)
        SparklineView(values: [5, 5, 5, 5, 5, 5, 5, 5], color: .gray)
            .frame(width: 40, height: 16)
    }
    .padding()
}
#endif
