import SwiftUI

struct WeatherIcon: View {
    let condition: WeatherCondition
    let isDaytime: Bool
    var size: CGFloat = 24

    private static let moonColor = Color(red: 0.85, green: 0.8, blue: 0.55)

    var body: some View {
        Image(systemName: condition.symbol(isDaytime: isDaytime))
            .symbolRenderingMode(renderingMode)
            .foregroundStyle(primaryColor, secondaryColor)
            .font(.system(size: size))
            .accessibilityLabel(condition.displayName)
    }

    private var renderingMode: SymbolRenderingMode {
        if !isDaytime, condition == .clear || condition == .mainlyClear || condition == .partlyCloudy {
            return .palette
        }
        return .multicolor
    }

    private var primaryColor: Color {
        if !isDaytime {
            switch condition {
                case .clear, .mainlyClear: return Self.moonColor
                case .partlyCloudy: return .gray
                default: break
            }
        }
        switch condition {
            case .clear, .mainlyClear: return .yellow
            case .partlyCloudy: return .blue
            case .cloudy, .fog: return .gray
            case .rain, .heavyRain, .showers, .heavyShowers, .drizzle: return .cyan
            case .snow, .heavySnow, .snowShowers, .sleet, .freezingDrizzle, .freezingRain: return .blue
            case .thunderstorm, .thunderstormWithHail: return .orange
        }
    }

    private var secondaryColor: Color {
        if !isDaytime {
            switch condition {
                case .clear, .mainlyClear: return Self.moonColor.opacity(0.6)
                case .partlyCloudy: return Self.moonColor
                default: break
            }
        }
        return primaryColor.opacity(0.6)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        WeatherIcon(condition: .clear, isDaytime: true, size: 32)
        WeatherIcon(condition: .clear, isDaytime: false, size: 32)
        WeatherIcon(condition: .rain, isDaytime: true, size: 32)
        WeatherIcon(condition: .snow, isDaytime: true, size: 32)
        WeatherIcon(condition: .thunderstorm, isDaytime: true, size: 32)
    }
    .padding()
}
#endif
