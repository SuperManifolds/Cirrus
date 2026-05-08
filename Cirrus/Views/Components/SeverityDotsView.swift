import SwiftUI

struct SeverityDotsView: View {
    let level: Int
    let maxLevel: Int
    let activeColor: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<maxLevel, id: \.self) { index in
                Circle()
                    .fill(index < level ? activeColor : .primary.opacity(0.1))
                    .frame(width: 5, height: 5)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 10) {
        SeverityDotsView(level: 1, maxLevel: 4, activeColor: .green)
        SeverityDotsView(level: 2, maxLevel: 4, activeColor: .yellow)
        SeverityDotsView(level: 3, maxLevel: 4, activeColor: .orange)
        SeverityDotsView(level: 4, maxLevel: 4, activeColor: .red)
    }
    .padding()
}
#endif
