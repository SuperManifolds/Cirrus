import SwiftUI

struct DayArcView: View {
    let sunrise: Date
    let sunset: Date
    let now: Date

    private var progress: Double {
        let dayLength = sunset.timeIntervalSince(sunrise)
        guard dayLength > 0 else { return 0.5 }
        return max(0, min(1, now.timeIntervalSince(sunrise) / dayLength))
    }

    var body: some View {
        GeometryReader { geometry in
            let dotSize = LayoutConstants.Size.arcDotSize
            let strokeWidth = LayoutConstants.Size.arcStrokeWidth
            let inset = dotSize / 2 + strokeWidth
            let radius = min(
                (geometry.size.width - inset * 2) / 2,
                geometry.size.height - inset
            )
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height)

            // Track
            SemiCircle()
                .stroke(.primary.opacity(0.12), lineWidth: strokeWidth)
                .frame(width: radius * 2, height: radius)
                .position(x: center.x, y: center.y - radius / 2)

            // Lit portion
            SemiCircle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius)
                .position(x: center.x, y: center.y - radius / 2)

            // Sun dot
            let angle = Double.pi * (1 - progress)
            let dotX = center.x + radius * cos(angle)
            let dotY = center.y - radius * sin(angle)

            Circle()
                .fill(.yellow)
                .frame(width: dotSize, height: dotSize)
                .shadow(color: .yellow.opacity(0.5), radius: 3)
                .position(x: dotX, y: dotY)
        }
        .accessibilityHidden(true)
    }
}

private struct SemiCircle: Shape {
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
    let now = Date()
    let sunrise = Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: now) ?? now
    let sunset = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: now) ?? now
    VStack(spacing: 20) {
        DayArcView(sunrise: sunrise, sunset: sunset, now: now)
            .frame(width: 50, height: 22)
        DayArcView(sunrise: sunrise, sunset: sunset,
                   now: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: now) ?? now)
            .frame(width: 50, height: 22)
        DayArcView(sunrise: sunrise, sunset: sunset,
                   now: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? now)
            .frame(width: 50, height: 22)
    }
    .padding()
}
#endif
