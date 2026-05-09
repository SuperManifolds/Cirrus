import SwiftUI

struct TemperatureRangeBar: View {
    let dayLow: Double
    let dayHigh: Double
    let weekMin: Double
    let weekMax: Double

    private static let tempColors: [(temp: Double, color: Color)] = [
        (-20, .purple),
        (-10, .blue),
        (0, .cyan),
        (10, .yellow),
        (20, .orange),
        (30, .red)
    ]

    var body: some View {
        GeometryReader { geometry in
            let range = weekMax - weekMin
            let startFraction = range > 0 ? (dayLow - weekMin) / range : 0
            let endFraction = range > 0 ? (dayHigh - weekMin) / range : 1
            let barWidth = max(4, geometry.size.width * (endFraction - startFraction))

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(.quaternary.opacity(0.5))
                    .frame(height: 4)

                // Gradient bar — spans full width, clipped to bar range
                Capsule()
                    .fill(fullGradient)
                    .frame(width: geometry.size.width, height: 4)
                    .offset(x: -geometry.size.width * startFraction)
                    .frame(width: barWidth, height: 4, alignment: .leading)
                    .clipShape(Capsule())
                    .offset(x: geometry.size.width * startFraction)
            }
        }
        .frame(height: 4)
    }

    private var fullGradient: LinearGradient {
        let range = weekMax - weekMin
        guard range > 0 else {
            return LinearGradient(colors: [colorForTemp(dayLow)], startPoint: .leading, endPoint: .trailing)
        }

        var stops: [Gradient.Stop] = Self.tempColors.compactMap { temp, color in
            let fraction = (temp - weekMin) / range
            guard fraction >= 0, fraction <= 1 else { return nil }
            return Gradient.Stop(color: color, location: fraction)
        }

        if stops.isEmpty || (stops.first?.location ?? 1) > 0 {
            stops.insert(Gradient.Stop(color: colorForTemp(weekMin), location: 0), at: 0)
        }
        if (stops.last?.location ?? 0) < 1 {
            stops.append(Gradient.Stop(color: colorForTemp(weekMax), location: 1))
        }

        return LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
    }

    private func colorForTemp(_ temp: Double) -> Color {
        let colors = Self.tempColors
        guard let first = colors.first, let last = colors.last else { return .gray }
        if temp <= first.temp { return first.color }
        if temp >= last.temp { return last.color }
        for idx in 1..<colors.count where temp <= colors[idx].temp {
            let prev = colors[idx - 1]
            let next = colors[idx]
            let fraction = (temp - prev.temp) / (next.temp - prev.temp)
            return fraction < 0.5 ? prev.color : next.color
        }
        return last.color
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 8) {
        TemperatureRangeBar(dayLow: -10, dayHigh: -2, weekMin: -15, weekMax: 5)
            .frame(width: 100)
        TemperatureRangeBar(dayLow: 8, dayHigh: 16, weekMin: 5, weekMax: 20)
            .frame(width: 100)
        TemperatureRangeBar(dayLow: 22, dayHigh: 32, weekMin: 18, weekMax: 35)
            .frame(width: 100)
        TemperatureRangeBar(dayLow: -5, dayHigh: 30, weekMin: -10, weekMax: 35)
            .frame(width: 100)
    }
    .padding()
}
#endif
