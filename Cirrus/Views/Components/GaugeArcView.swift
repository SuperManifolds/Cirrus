import SwiftUI

struct GaugeArcView: View {
    let value: Double
    let maxValue: Double
    let colors: [Color]

    private var fraction: Double {
        max(0, min(1, value / maxValue))
    }

    var body: some View {
        GeometryReader { geometry in
            let strokeWidth = LayoutConstants.Size.gaugeStrokeWidth
            let radius = min(
                (geometry.size.width - strokeWidth) / 2,
                geometry.size.height - strokeWidth / 2
            )
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height)

            // Track
            SemiArc()
                .stroke(.primary.opacity(0.08), lineWidth: strokeWidth)
                .frame(width: radius * 2, height: radius)
                .position(x: center.x, y: center.y - radius / 2)

            // Filled portion
            SemiArc()
                .trim(from: 0, to: fraction)
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius)
                .position(x: center.x, y: center.y - radius / 2)

        }
    }

    private func interpolateColor(fraction: Double) -> Color {
        guard colors.count >= 2 else { return colors.first ?? .gray }
        let segment = fraction * Double(colors.count - 1)
        let index = min(Int(segment), colors.count - 2)
        return colors[index]
    }
}

private struct SemiArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 20) {
        GaugeArcView(value: 15, maxValue: 100, colors: [.green, .yellow, .orange, .red])
            .frame(width: 50, height: 22)
        GaugeArcView(value: 60, maxValue: 100, colors: [.green, .yellow, .orange, .red])
            .frame(width: 50, height: 22)
        GaugeArcView(value: 200, maxValue: 300, colors: [.green, .yellow, .red, .purple])
            .frame(width: 50, height: 22)
    }
    .padding()
}
#endif
