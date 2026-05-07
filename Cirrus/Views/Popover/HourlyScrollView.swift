import SwiftUI

struct HourlyScrollView: View {
    let forecasts: [HourlyForecast]
    let unit: TemperatureUnit

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 4) {
                ForEach(Array(forecasts.enumerated()), id: \.element.id) { index, forecast in
                    HourlyForecastRow(forecast: forecast, unit: unit, isNow: index == 0)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 90)
    }
}

#if DEBUG
#Preview {
    let forecasts = MockWeatherProvider.mockHourly()
    HourlyScrollView(forecasts: forecasts, unit: .celsius)
        .frame(width: 320)
}
#endif
