import SwiftUI

struct WeatherDetailCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = .secondary
    var directionDegrees: Double?
    var trendValues: [Double]?
    var trendColor: Color?
    var customVisual: AnyView?
    var visualPlacement: CardVisualPlacement = .inline

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
            HStack(spacing: 4) {
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
                if let degrees = directionDegrees {
                    Image(systemName: "arrow.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(degrees))
                }
                Spacer()
                if let visual = customVisual, visualPlacement == .inline {
                    visual
                } else if customVisual == nil, let values = trendValues, values.count >= 2 {
                    SparklineView(values: values, color: trendColor ?? iconColor)
                        .frame(width: LayoutConstants.Size.sparklineWidth, height: LayoutConstants.Size.sparklineHeight)
                }
            }
            if let visual = customVisual, visualPlacement == .fullWidth {
                visual
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(LayoutConstants.Padding.card)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                .fill(.primary.opacity(LayoutConstants.Opacity.cardFill))
        )
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(LayoutConstants.Opacity.cardBorderTop),
                            .white.opacity(LayoutConstants.Opacity.cardBorderBottom)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: LayoutConstants.Opacity.cardBorderWidth
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "\(title): \(value)"))
    }
}

#if DEBUG
#Preview {
    HStack {
        WeatherDetailCard(title: "Wind", value: "12 km/h", icon: "wind")
        WeatherDetailCard(title: "Humidity", value: "55%", icon: "humidity.fill")
    }
    .padding()
    .frame(width: WeatherDefaults.popoverWidth)
}
#endif
