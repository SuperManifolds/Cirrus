import SwiftUI

struct SparklineView: View {
    let values: [Double]
    var color: Color = .secondary

    var body: some View {
        GeometryReader { geometry in
            let minVal = values.min() ?? 0
            let maxVal = values.max() ?? 1
            let range = maxVal - minVal
            let safeRange = range > 0 ? range : 1

            Path { path in
                for (index, value) in values.enumerated() {
                    let pointX = geometry.size.width * Double(index) / Double(values.count - 1)
                    let pointY = geometry.size.height * (1 - (value - minVal) / safeRange)

                    if index == 0 {
                        path.move(to: CGPoint(x: pointX, y: pointY))
                    } else {
                        path.addLine(to: CGPoint(x: pointX, y: pointY))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        }
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
