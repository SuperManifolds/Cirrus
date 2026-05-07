import SwiftUI

struct WeatherIcon: View {
    let condition: WeatherCondition
    let isDaytime: Bool
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: condition.symbol(isDaytime: isDaytime))
            .symbolRenderingMode(.multicolor)
            .font(.system(size: size))
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
