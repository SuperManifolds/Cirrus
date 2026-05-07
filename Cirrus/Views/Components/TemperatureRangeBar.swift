import SwiftUI

struct TemperatureRangeBar: View {
    let dayLow: Double
    let dayHigh: Double
    let weekMin: Double
    let weekMax: Double

    var body: some View {
        GeometryReader { geometry in
            let range = weekMax - weekMin
            let startFraction = range > 0 ? (dayLow - weekMin) / range : 0
            let endFraction = range > 0 ? (dayHigh - weekMin) / range : 1

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(4, geometry.size.width * (endFraction - startFraction)),
                        height: 4
                    )
                    .offset(x: geometry.size.width * startFraction)
            }
        }
        .frame(height: 4)
    }
}

#if DEBUG
#Preview {
    TemperatureRangeBar(dayLow: 14, dayHigh: 24, weekMin: 10, weekMax: 28)
        .frame(width: 100)
        .padding()
}
#endif
