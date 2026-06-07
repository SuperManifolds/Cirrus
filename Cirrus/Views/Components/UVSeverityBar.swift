import SwiftUI

struct UVSeverityBar: View {
    let uvIndex: Double

    private var fraction: Double {
        min(uvIndex / 11.0, 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(.primary.opacity(0.08))

                // Filled portion — gradient spans full width, clipped to filled range
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width)
                    .frame(width: geometry.size.width * fraction, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 10) {
        UVSeverityBar(uvIndex: 2).frame(width: 100, height: 4)
        UVSeverityBar(uvIndex: 5).frame(width: 100, height: 4)
        UVSeverityBar(uvIndex: 8).frame(width: 100, height: 4)
        UVSeverityBar(uvIndex: 11).frame(width: 100, height: 4)
    }
    .padding()
}
#endif
