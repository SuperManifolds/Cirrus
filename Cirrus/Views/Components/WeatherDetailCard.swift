import SwiftUI

struct WeatherDetailCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
            }
            .font(.caption2)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary.opacity(0.05))
                .stroke(.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#if DEBUG
#Preview {
    HStack {
        WeatherDetailCard(title: "Wind", value: "12 km/h", icon: "wind")
        WeatherDetailCard(title: "Humidity", value: "55%", icon: "humidity.fill")
    }
    .padding()
    .frame(width: 320)
}
#endif
