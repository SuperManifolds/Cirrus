import SwiftUI

struct DepthBarView: View {
    let depth: Double
    let maxDepth: Double

    var body: some View {
        let fraction = min(depth / maxDepth, 1.0)
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.depthBar)
                    .fill(.primary.opacity(0.08))

                RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.depthBar)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .blue.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * fraction)
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 10) {
        DepthBarView(depth: 5, maxDepth: 50)
            .frame(width: 8, height: 20)
        DepthBarView(depth: 25, maxDepth: 50)
            .frame(width: 8, height: 20)
        DepthBarView(depth: 50, maxDepth: 50)
            .frame(width: 8, height: 20)
    }
    .padding()
}
#endif
